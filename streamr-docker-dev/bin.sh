#!/bin/bash

ORIG_FILENAME="$(readlink "$0" -f)"
ORIG_DIRNAME=$(dirname "$ORIG_FILENAME")
ROOT_DIR="$ORIG_DIRNAME/.."

OPERATION=
COMMANDS_TO_RUN=()

SERVICES=""
FLAGS=""
DETACHED=1
DRY_RUN=0
FOLLOW=0
HELP=0

help() {
    "$ORIG_DIRNAME/help_scripts.sh" $SERVICES
    exit
}

start() {
    ip_lines=$(ifconfig | grep -c 10.200.10.1)
    if [ "$ip_lines" -eq "0" ]; then
        COMMANDS_TO_RUN+=("echo Binding the internal IP address to the loopback interface.")
        COMMANDS_TO_RUN+=("echo This requires sudo privileges, so please provide your password if requested")
        COMMANDS_TO_RUN+=("sudo ifconfig lo0 alias 10.200.10.1/24")
    fi
    [[ $DETACHED == 1 ]] && FLAGS+=" -d"
    [[ $SERVICES == "" ]] && msg="Starting all" || msg="Starting$SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("docker-compose up $FLAGS $SERVICES")
}

stop() {
    [[ $SERVICES == "" ]] && msg="Stopping all" || msg="Stopping$SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("docker-compose kill $SERVICES")
    COMMANDS_TO_RUN+=("docker-compose rm -f $SERVICES")
}

restart() {
    stop && COMMANDS_TO_RUN+=("printf \n") && start
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
            -f | --follow )             FOLLOW=1
                                        ;;
            --dry-run )                 DRY_RUN=1
                                        ;;
            --attached )                DETACHED=0
                                        ;;
            * )                         echo "Invalid option: $1"
                                        exit
                                        ;;
        esac
    else
        SERVICES+=" $1"
    fi
    shift
done

# Populate COMMANDS_TO_RUN by executing the relevant method
case $OPERATION in
    help )                          help
                                    ;;
    start )                         start
                                    ;;
    stop )                          stop
                                    ;;
    restart )                       restart
                                    ;;
    ps )                            ps
                                    ;;
    log )                           log
                                    ;;
    pull )                          pull
                                    ;;
    wipe )                          wipe
                                    ;;
    factory-reset)                  factory-reset
                                    ;;
    * )                             "$ORIG_DIRNAME/help_scripts.sh"
                                    exit
                                    ;;
esac

# Run or dry-run COMMANDS_TO_RUN
cd "$ROOT_DIR" || exit 1
for command in "${COMMANDS_TO_RUN[@]}"
do
    if [ $DRY_RUN == 1 ]; then
        echo "$command"
    else
        $command
    fi
done


