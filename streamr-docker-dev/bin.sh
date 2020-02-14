#!/bin/bash

ORIG_FILENAME="$(readlink "$0" -f)"
ORIG_DIRNAME=$(dirname "$ORIG_FILENAME")
ROOT_DIR="$ORIG_DIRNAME/.."

OPERATION=
COMMANDS_TO_RUN=()

FIRST_START_ARGUMENTS=""
SERVICES=""
FLAGS=""
DETACHED=1
ALL=0
DRY_RUN=0
FOLLOW=0
HELP=0

help() {
    $ORIG_DIRNAME/help_scripts.sh
    exit
}

start() {
    ip_lines=$(ifconfig | grep -c 10.200.10.1)
    if [ "$ip_lines" -eq "0" ]; then
       echo "WARNING: bind-ip is not set! Setting it now."
       bind_ip
    fi
    [[ $DETACHED == 1 ]] && FLAGS+=" -d"
    [[ $SERVICES == "" ]] && msg="Starting all" || msg="Starting$SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    COMMANDS_TO_RUN+=("docker-compose $FIRST_START_ARGUMENTS up $FLAGS $SERVICES")
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

wipe() {
    stop
    COMMANDS_TO_RUN+=("echo Deleting persistent data")
    COMMANDS_TO_RUN+=("rm -rf ./data")
}

ps() {
    COMMANDS_TO_RUN+=("docker-compose ps$SERVICES")
}

log() {
    FLAGS+=" -t --tail=1000"
    if [ $FOLLOW == 1 ];then
        FLAGS+=" -f"
    fi
    COMMANDS_TO_RUN+=("docker-compose logs$FLAGS$SERVICES")
}

bind_ip() {
    COMMANDS_TO_RUN+=("echo Binding the ip addresses requires to be run as sudo and therefore a sudo user's password is required")
    COMMANDS_TO_RUN+=("sudo ifconfig lo0 alias 10.200.10.1/24")
}

pull() {
    # Pull latest images define on docker compose
    COMMANDS_TO_RUN+=("docker-compose pull $SERVICES")
}

clean() {
    COMMANDS_TO_RUN+=("echo Stopping all")
    COMMANDS_TO_RUN+=("docker-compose kill")
    COMMANDS_TO_RUN+=("docker system prune --all --force --volumes")
}

OPERATION=$1
shift

# Read arguments & options
while [ $# -gt 0 ]; do # if there are arguments
    if [[ "$1" = -* ]]; then
        case $1 in
            -h | --help )               HELP=1
                                        ;;
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

if [ $HELP == 1 ]; then
    $ORIG_DIRNAME/help_scripts.sh "$OPERATION"
    exit
fi

# Populate COMMANDS_TO_RUN by executing the relevant method
case $OPERATION in
    help | -h | --help )            help
                                    ;;
    start )                         start
                                    ;;
    stop )                          stop
                                    ;;
    restart )                       restart
                                    ;;
    wipe )                          wipe
                                    ;;
    ps )                            ps
                                    ;;
    log )                           log
                                    ;;
    pull )                          pull
                                    ;;
    clean)                          clean
                                    ;;
    * )                             $ORIG_DIRNAME/help_scripts.sh
                                    exit
                                    ;;
esac

# Run or dry-run COMMANDS_TO_RUN
pushd $ROOT_DIR > /dev/null
for command in "${COMMANDS_TO_RUN[@]}"
do
    if [ $DRY_RUN == 1 ]; then
        echo "$command"
    else
        $command
    fi
done
popd > /dev/null

