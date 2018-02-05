#!/bin/bash

ORIG_FILENAME="$(readlink "$0" -f)"
ORIG_DIRNAME=$(dirname "$ORIG_FILENAME")
ROOT_DIR="$ORIG_DIRNAME/.."
ARGUMENTS=$#

OPERATION=
COMMANDS_TO_RUN=()

FIRST_START_ARGUMENTS=""
SERVICES=""
FLAGS=""
DETACHED=1
RESTART=0
REMOVE_DATA=0
KILL_ALL=0
ALL=0
DRY_RUN=0
FOLLOW=0
HELP=0

SERVICE_COMBINATIONS=("" "mysql broker data-api" "mysql data-api" "mysql broker")

help() {
    $ORIG_DIRNAME/help_scripts.sh
    exit
}

check_services_from_arguments() {
    if [ "$SERVICES" == "" ] && [ $ALL == 0 ]; then
        echo No services specified. Use option --all if you want to "$OPERATION" all services.
        exit
    fi
}

start() {
    check_services_from_arguments
    [[ $DETACHED == 1 ]] && FLAGS+=" -d"
    [[ $SERVICES == "" ]] && msg="Starting all" || msg="Starting$SERVICES"
    COMMANDS_TO_RUN+=("echo $msg")
    
    COMMANDS_TO_RUN+=("docker-compose$FIRST_START_ARGUMENTS up$FLAGS$SERVICES")
}

stop() {
    check_services_from_arguments
    [[ $KILL_ALL == 1 ]] && ARGUMENTS="" || ARGUMENTS=$SERVICES

    [[ $ARGUMENTS == "" ]] && msg="Stopping all" || msg="Stopping$ARGUMENTS"
    COMMANDS_TO_RUN+=("echo $msg")

    COMMANDS_TO_RUN+=("docker-compose kill$ARGUMENTS")
    COMMANDS_TO_RUN+=("docker-compose rm -f$ARGUMENTS")

    if [ $REMOVE_DATA == 1 ]; then
        COMMANDS_TO_RUN+=("echo Deleting persistent data")
        COMMANDS_TO_RUN+=("rm -rf ./data")
    fi
}

restart() {
    stop && COMMANDS_TO_RUN+=("printf \n") && start
}

ps() {
    COMMANDS_TO_RUN+=("docker-compose ps$SERVICES")
}

log() {
    FLAGS+=" -t"
    if [ $FOLLOW == 1 ];then
        FLAGS+=" -f"
    fi
    COMMANDS_TO_RUN+=("docker-compose logs$FLAGS$SERVICES")
}

bind_ip() {
    COMMANDS_TO_RUN+=("echo Binding the ip addresses requires to be run as sudo and therefore a sudo user's password is required")
    COMMANDS_TO_RUN+=("sudo ifconfig lo0 alias 10.200.10.1/24")
}

interactive() {
    PS3="Operation: [type or select from list] > "
    options=(
        "start" 
        "stop" 
        "restart" 
        "ps" 
        "log"
        "bind-ip"
        "help"
    )
    select opt in "${options[@]}"; do
        case $REPLY in
            1 )
                OPERATION="start"
                break
                ;;
            2 )
                OPERATION="stop"
                break
                ;;
            3 )
                OPERATION="restart"
                break
                ;;
            4 )
                OPERATION="ps"
                break
                ;;
            5 )
                OPERATION="log"
                break
                ;;
            6 )
                OPERATION="bind-ip"
                break
                ;;
            7 )
                help
                break
                ;;
            * )
                OPERATION=$REPLY
                if [[ ! " ${options[@]} " =~ " ${REPLY} " ]]; then
                    printf "Invalid operation"
                    exit
                fi
                break
                ;;
        esac
    done
    printf "\n"

    response=

    ask_for_services=(
        "start"
        "stop"
        "restart"
        "log"
    )
    if [[ " ${ask_for_services[@]} " =~ " ${OPERATION} " ]]; then
        PS3="Services: [type or select bundle from list] > "
        options=(
            "Broker + Data-API + base services"
            "Data-API + base services"
            "Broker + base services"
            "3rd party + base services"
            "entire stack"
        )
        select opt in "${options[@]}"
        do
            temp=""
            case $REPLY in
                1 | 2 | 3 )         temp=${SERVICE_COMBINATIONS[$REPLY]}
                                    ;;
                4 )                 FIRST_START_ARGUMENTS+=" -f docker-compose.yml"
                                    ;;
                5 )                 ALL=1
                                    ;;
                * )                 temp=$REPLY
                                    ;;
            esac
            SERVICES=" $temp"
            break
        done

        if [ "$OPERATION" == "stop" ] || [ "$OPERATION" == "restart" ]; then
            if [ $ALL == 0 ]; then
                printf "Stop other services also? [Y/n] > "
                read response
                if [ "$response" == "Y" ] || [ "$response" == "y" ]; then
                    KILL_ALL=1
                fi
            fi
            printf "\n"

            printf "Remove persistent data? [Y/n] > "
            read response
            if [ "$response" == "Y" ] || [ "$response" == "y" ]; then
                REMOVE_DATA=1
            fi
            printf "\n"
        elif [ "$OPERATION" == "log" ]; then
            printf "Follow log? [Y/n] > "
            read response
            if [ "$response" == "Y" ] || [ "$response" == "y" ]; then
                FOLLOW=1
            fi
        fi
    elif [ "$OPERATION" == "bind-ip" ]; then
        bind_ip
    elif [ "$OPERATION" == "help" ]; then
        help
    fi
}

if [ $# == 0 ]; then
    interactive
else
    OPERATION=$1
    shift

    # Read arguments & options
    while [ $# -gt 0 ]; do # if there are arguments
        if [[ "$1" = -* ]]; then
            case $1 in
                -h | --help )               HELP=1
                                            ;;
                -a | --all )                ALL=1
                                            ;;
                -r | --remove-data )        REMOVE_DATA=1
                                            ;;
                -k | --kill-all )           KILL_ALL=1
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
            case $1 in
                1 | 2 | 3)  SERVICES+=" ${SERVICE_COMBINATIONS[$1]}"
                            ;;
                4 )         FIRST_START_ARGUMENTS+=" -f docker-compose.yml"
                            SERVICES+=" "
                            ;;
                5 )         ALL=1
                            ;;
                * )         SERVICES+=" $1"
                            ;;
            esac
        fi
        shift
    done
fi

if [ $HELP == 1 ]; then
    $ORIG_DIRNAME/help_scripts.sh "$OPERATION"
    exit
fi

case $OPERATION in
    help | -h | --help )            help
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
    "bind-ip" )                     bind_ip
                                    ;;
esac
    

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

