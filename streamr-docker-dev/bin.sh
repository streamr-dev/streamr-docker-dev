#!/bin/bash

ORIG_FILENAME="$(readlink "$0" -f)"
ORIG_DIRNAME=$(dirname "$ORIG_FILENAME")
ROOT_DIR="$ORIG_DIRNAME/.."
CONTAINER_PREFIX="streamr-dev-"

OPERATION=
COMMANDS_TO_RUN=()

SERVICES=""
EXCEPT_SERVICES=()
FLAGS=""
DETACHED=1
DRY_RUN=0
FOLLOW=0
WAIT=0
WAIT_TIMEOUT=300     # seconds
DOCKER_COMPOSE="docker-compose --ansi never"

# don't start these services unless explicitly started
EXCEPT_SERVICES_DEFAULT=() # array of string e.g. ("a" "b")

# Service Aliases
NODE_NO_STORAGE='broker-node-no-storage-1 broker-node-no-storage-2'
NODE_STORAGE='broker-node-storage-1'
NODES="$NODE_NO_STORAGE $NODE_STORAGE"
TRACKERS='tracker-1 tracker-2 tracker-3'

# swap aliases for full names e.g. trackers = tracker-1 tracker-2 tracker-3
# feel free to add more, just make sure you don't end up using actual service
# names as alias names
expandServiceAliases() {
    local names=$1
    names="${names//node-no-storage/$NODE_NO_STORAGE}"
    names="${names//no-storage-nodes/$NODE_NO_STORAGE}"
    names="${names//node-storage/$NODE_STORAGE}"
    names="${names//storage-nodes/$NODE_STORAGE}"
    names="${names//brokers/$NODES}"
    names="${names//nodes/$NODES}" # brokers/nodes sort of interchangeable
    names="${names//trackers/$TRACKERS}"
    echo "$names"
}

# Execute all commands from the root dir of streamr-docker-dev
cd "$ROOT_DIR" || exit 1

if [ -f .env ]; then
    # Read .env (from https://stackoverflow.com/questions/19331497/set-environment-variables-from-file-of-key-value-pairs/20909045#20909045)
    set -o allexport
    source .env
    set +o allexport
fi
# Set default values for required env variables if not set in .env
if [[ -z "${STREAMR_BASE_URL}" ]]; then
    export STREAMR_BASE_URL=http://10.200.10.1
else
    echo "Using STREAMR_BASE_URL: ${STREAMR_BASE_URL}"
fi

if [[ -z "${STREAMR_WS_URL}" ]]; then
    export STREAMR_WS_URL=${STREAMR_BASE_URL/http/ws}/api/v1/ws # replace "http" with "ws"
else
    echo "Using STREAMR_WS_URL: ${STREAMR_WS_URL}"
fi

help() {
    "$ORIG_DIRNAME/help_scripts.sh" $SERVICES
}

services() {
    $DOCKER_COMPOSE config --services
}

start() {
    ip_lines=$(ifconfig | grep -c 10.200.10.1)
    if [ "$ip_lines" -eq "0" ]; then
        COMMANDS_TO_RUN+=("echo Binding the internal IP address 10.200.10.1 to the loopback interface.")
        COMMANDS_TO_RUN+=("echo This requires sudo privileges, so please provide your password if requested")

        # Binding the loopback address is OS-specific
        if [ "$(uname)" == "Darwin" ]; then
            COMMANDS_TO_RUN+=("sudo ifconfig lo0 alias 10.200.10.1/24")
        elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
            COMMANDS_TO_RUN+=("sudo ip addr add 10.200.10.1 dev lo label lo:1")
        #elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
            # TODO: bind under 32 bits Windows NT platform
            # maybe something like this: netsh interface ip add address "loopback" 10.200.10.1 255.255.255.255
        #elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
            # TODO: bind under 64 bits Windows NT platform
        fi
    fi
    [[ $DETACHED == 1 ]] && FLAGS+=" -d"
    [[ $SERVICES == "" ]] && msg="Starting all" || msg="Starting $SERVICES"

    # only start these if started explicitly
    for service in "${EXCEPT_SERVICES_DEFAULT[@]}"
    do
        if [[ ! "$SERVICES" =~ $service  ]]; then
            EXCEPT_SERVICES+=("$service")
        fi
    done

    # use --scale $service=0 to prevent start of --except services
    [[ ! "${#EXCEPT_SERVICES[@]}" -eq 0 ]] && msg+=" except:"
    for service in "${EXCEPT_SERVICES[@]}"
    do
        msg+=" $service"
        FLAGS+=" --scale $service=0"
    done

    FLAGS+=" --remove-orphans"

    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE up $FLAGS $SERVICES")

    if [ $WAIT == 1 ]; then
        COMMANDS_TO_RUN+=("wait")
    fi
}

stop() {
    [[ $SERVICES == "" ]] && msg="Stopping all" || msg="Stopping $SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE kill $SERVICES")
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE rm -f $SERVICES")
}

restart() {
    stop && COMMANDS_TO_RUN+=("printf \n") && start
}

wait() {
    echo "Waiting for pending health checks to pass (timeout: $WAIT_TIMEOUT sec)..."
    declare -i time_waited
    while [[ $time_waited -lt $WAIT_TIMEOUT ]]; do
        waiting_for_services=()

        # Get the id of each image we have in docker-compose
        for image_id in $($DOCKER_COMPOSE ps -q)
        do
            service_name=$(docker inspect -f "{{.Name}}" "$image_id")
            # Try to read health state of each image
            health_state=$(docker inspect -f "{{.State.Health.Status}}" "$image_id" 2> /dev/null)
            if [ $? -eq 0 ]; then
                # Successfully got health state. Is the service healthy?
                if [ "$health_state" != "healthy" ]; then
                    waiting_for_services+=("$service_name ($health_state)")
                fi
            else
                # Error while fetching health state. Maybe a health check is not configured. Did the image exit successfully?
                exit_status=$(docker inspect -f "{{.State.Status}}" "$image_id")
                exit_code=$(docker inspect -f "{{.State.ExitCode}}" "$image_id")
                if [ "$exit_status" != "exited" ]; then
                    # Didn't exit yet, keep waiting...
                    waiting_for_services+=("$service_name (no health check -> waiting for it to exit)")
                elif [ "$exit_code" != "0" ]; then
                    # Exited but errored
                    waiting_for_services+=("$service_name (ERROR: exit code $exit_code)")
                fi
            fi
        done

        if [ ${#waiting_for_services[@]} -gt 0 ]; then
            if (( time_waited >= 60 )); then
                echo "***********************************"
                echo "Still waiting for the following services:"
                for s in "${waiting_for_services[@]}"; do echo "$s"; done
            fi
            sleep 10s
            time_waited=$((time_waited+10))
        else
            echo "All services up and running."
            break
        fi
    done

    if [[ $time_waited -ge $WAIT_TIMEOUT ]]; then
        echo "ERROR: Timed out waiting for health checks to pass. (Timeout: $WAIT_TIMEOUT sec)"
        exit 1
    fi
}

ps() {
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE ps $SERVICES")
}

log() {
    FLAGS+=" -t --tail=1000"
    if [ $FOLLOW == 1 ];then
        FLAGS+=" -f"
    fi
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE logs $FLAGS $SERVICES")
}

shell() {
    # Assumes standardized container names that begin with $CONTAINER_PREFIX
    COMMANDS_TO_RUN+=("docker exec -ti $CONTAINER_PREFIX$SERVICES /bin/sh")
}

pull() {
    # Pull latest images define on docker compose
    COMMANDS_TO_RUN+=("$DOCKER_COMPOSE pull $SERVICES")
}

update() {
    # git pull latest version
    COMMANDS_TO_RUN+=("git pull")
}

wipe() {
    stop
    COMMANDS_TO_RUN+=("echo Wiping persistent data of services")
    COMMANDS_TO_RUN+=("docker volume prune -f")
}

factory-reset() {
    wipe
    COMMANDS_TO_RUN+=("echo Pruning docker images. This may take a while...")
    COMMANDS_TO_RUN+=("docker system prune --all --force --volumes")
}

OPERATION=$1
shift

# Read arguments & options
while [ $# -gt 0 ]; do # if there are arguments
    if [[ "$1" = -* ]]; then
        case $1 in
        --except )
            EXCEPT_SERVICES+=("$2")
            shift # skip over the next arg, which was already consumed above
            ;;
        --wait )
            WAIT=1
           ;;
        --timeout )
            WAIT_TIMEOUT=$2
            shift # skip over the next arg, which was already consumed above
            ;;
        -f | --follow )
            FOLLOW=1
            ;;
        --dry-run )
            DRY_RUN=1
            ;;
        --attached )
            DETACHED=0
            ;;
        * )
            help
            echo "ERROR: Invalid option: $1"
            exit 1
            ;;
        esac
    else
        SERVICES+="$1 "
    fi
    shift
done

EXCEPT_SERVICES_DEFAULT=($(expandServiceAliases "${EXCEPT_SERVICES_DEFAULT[*]}"))
SERVICES=$(expandServiceAliases "$SERVICES")
EXCEPT_SERVICES=($(expandServiceAliases "${EXCEPT_SERVICES[*]}"))

# Populate COMMANDS_TO_RUN by executing the relevant method
case $OPERATION in
"" | help )
    help
    ;;
start )
    start
    ;;
stop )
    stop
    ;;
restart )
    restart
    ;;
wait )
    wait
    ;;
ps )
    ps
    ;;
log )
    log
    ;;
shell )
    shell
    ;;
pull )
    pull
    ;;
update )
    update
    ;;
wipe )
    wipe
    ;;
factory-reset )
    factory-reset
    ;;
services )
    services
    ;;
* )
    help
    echo "ERROR: Invalid command: $OPERATION"
    exit 1
    ;;
esac

# Run or dry-run COMMANDS_TO_RUN
for command in "${COMMANDS_TO_RUN[@]}"
do
    if [ $DRY_RUN == 1 ]; then
        echo "$command"
    else
        $command
    fi
done
