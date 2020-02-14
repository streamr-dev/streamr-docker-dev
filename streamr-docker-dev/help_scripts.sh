#!/usr/bin/env bash

common_help() {
echo "
streamr-docker-dev – Streamr Docker Developer Environment.

Usage: streamr-docker-dev [<command> [options] [--] <service>...]
    streamr-docker-dev start
    streamr-docker-dev stop -r tracker
    streamr-docker-dev pull

Commands:
    help                show this screen
    start               start services
    stop                stop services
    restart             stop and start services
    ps                  list docker containers
    log                 show logs
    pull                pulls images
    wipe                wipes the data persisted by all services
    factory-reset       removes images and generated files

Options:
    -h --help           command help
    --dry-run           echo commands instead of executing them

Show command-specific options:
	streamr-docker-dev <command> -h
"
}

start_help() {
echo "
Starts the given services, or all services if none are specified.

Usage: streamr-docker-dev start [--] <service>...
    streamr-docker-dev start
    streamr-docker-dev start tracker ganache

Options:
    --attached          start in attached mode
"
}

stop_help() {
echo "
Stops the given services, or all services if none are specified.

Usage: streamr-docker-dev stop [options] [--] <service>...
    streamr-docker-dev stop
    streamr-docker-dev stop tracker
    streamr-docker-dev stop -r tracker ganache
"
}

restart_help() {
echo "
Restarts the given services, or all services if none are specified

Usage: streamr-docker-dev restart [options] [--] <service>...
    streamr-docker-dev restart
    streamr-docker-dev restart tracker
    streamr-docker-dev restart -r tracker ganache
"
}

ps_help() {
echo "
Shows currently running services. If no services given, shows all

Usage: streamr-docker-dev ps [<service>...]
    streamr-docker-dev ps
    streamr-docker-dev ps tracker
"
}

log_help() {
echo "
Shows the logs of the given services

Usage: streamr-docker-dev log [[options] [--] <service>...]
    streamr-docker-dev log
    streamr-docker-dev log tracker ganache
    streamr-docker-dev log -f tracker ganache

Options:
    -f --follow        	    follow log in realtime
"
}

pull_help() {
echo "
Pulls images defined in docker-compose files. If no services are given, pulls all of them.

Usage: streamr-docker-dev pull [ [--] <service>...]
    streamr-docker-dev pull
    streamr-docker-dev pull tracker ganache
"
}

wipe_help() {
echo "
Wipes the data persisted by all services.

Usage: streamr-docker-dev wipe
"
}

factory-reset_help() {
    echo "
Resets the environment by removing all persisted data and all related Docker images.

Usage: streamr-docker-dev factory-reset
"
}

case $1 in
    "start" )
        start_help
        ;;
    "stop" )
        stop_help
        ;;
    "restart" )
        restart_help
        ;;
    "wipe" )
        wipe_help
        ;;
    "ps" )
        ps_help
        ;;
    "log" )
        log_help
        ;;
    "pull" )
        pull_help
        ;;
    "factory-reset" )
        factory-reset_help
        ;;
    * ) common_help
        ;;
esac
