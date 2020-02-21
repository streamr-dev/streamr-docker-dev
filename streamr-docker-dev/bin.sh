#!/bin/bash

ORIG_FILENAME="$(readlink "$0" -f)"
ORIG_DIRNAME=$(dirname "$ORIG_FILENAME")
ROOT_DIR="$ORIG_DIRNAME/.."
CONTAINER_PREFIX="streamr-dev-"

OPERATION=
COMMANDS_TO_RUN=()

SERVICES=""
EXCEPT_SERVICES=""
FLAGS=""
DETACHED=1
DRY_RUN=0
FOLLOW=0
WAIT=0
WAIT_TIMEOUT=300     # seconds

# Execute all commands from the root dir of streamr-docker-dev
cd "$ROOT_DIR" || exit 1

help() {
    "$ORIG_DIRNAME/help_scripts.sh" $SERVICES
}

start() {
    ip_lines=$(ifconfig | grep -c 10.200.10.1)
    if [ "$ip_lines" -eq "0" ]; then
        COMMANDS_TO_RUN+=("echo Binding the internal IP address to the loopback interface.")
        COMMANDS_TO_RUN+=("echo This requires sudo privileges, so please provide your password if requested")
        COMMANDS_TO_RUN+=("sudo ifconfig lo0 alias 10.200.10.1/24")
    fi
    [[ $DETACHED == 1 ]] && FLAGS+=" -d"
    [[ $SERVICES == "" ]] && msg="Starting all" || msg="Starting $SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("docker-compose up $FLAGS $SERVICES")

    # "--except" feature is implemented by starting all, then stopping the unwanted services.
    # Bit of a hack but docker-compose doesn't provide a better direct way.
    if [[ $EXCEPT_SERVICES != "" ]]; then
        COMMANDS_TO_RUN+=("docker-compose kill $EXCEPT_SERVICES")
        COMMANDS_TO_RUN+=("docker-compose rm -f $EXCEPT_SERVICES")
    fi

    if [ $WAIT == 1 ]; then
        COMMANDS_TO_RUN+=("wait")
    fi
}

stop() {
    [[ $SERVICES == "" ]] && msg="Stopping all" || msg="Stopping $SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("docker-compose kill $SERVICES")
    COMMANDS_TO_RUN+=("docker-compose rm -f $SERVICES")
}

restart() {
    stop && COMMANDS_TO_RUN+=("printf \n") && start
}

wait() {
    # Warning: depends on docker-compose ps output, could break easily
    echo "Waiting for pending health checks to pass (timeout: $WAIT_TIMEOUT sec)..."
    declare -i time_waited
    while [[ $time_waited -lt $WAIT_TIMEOUT ]]; do
        # Are there lines that contain "health" (have health checks) but are not "healthy"?
        if docker-compose ps | grep health | grep -q -v healthy; then
            sleep 10s
            time_waited=$((time_waited+10))
        else
            break
        fi
    done

    if [[ $time_waited -ge $WAIT_TIMEOUT ]]; then
        echo "ERROR: Timed out waiting for health checks to pass. (Timeout: $WAIT_TIMEOUT sec)"
        exit 1
    fi
}

ps() {
    COMMANDS_TO_RUN+=("docker-compose ps $SERVICES")
}

log() {
    FLAGS+=" -t --tail=1000"
    if [ $FOLLOW == 1 ];then
        FLAGS+=" -f"
    fi
    COMMANDS_TO_RUN+=("docker-compose logs $FLAGS $SERVICES")
}

shell() {
    # Assumes standardized container names that begin with $CONTAINER_PREFIX
    COMMANDS_TO_RUN+=("docker exec -ti $CONTAINER_PREFIX$SERVICES /bin/sh")
}

pull() {
    # Pull latest images define on docker compose
    COMMANDS_TO_RUN+=("docker-compose pull $SERVICES")
}

wipe() {
    stop
    COMMANDS_TO_RUN+=("echo Wiping persistent data of services")
    COMMANDS_TO_RUN+=("rm -rf ./data")
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
            EXCEPT_SERVICES+="$2 "
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
wipe )
    wipe
    ;;
factory-reset )
    factory-reset
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


