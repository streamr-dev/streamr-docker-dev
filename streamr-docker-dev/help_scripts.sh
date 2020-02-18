#!/usr/bin/env bash

common_help() {
echo "
streamr-docker-dev – Streamr Docker Developer Environment.

Usage: streamr-docker-dev [<command> [options] [--] <service>...]

Commands:
    help                show this screen
    start               start services
    stop                stop services
    restart             stop and start services
    wait                wait for all health checks to pass
    ps                  list docker containers
    log                 show logs
    shell               shell into a container
    pull                pulls images
    wipe                wipes the data persisted by all services
    factory-reset       removes images and generated files


Examples:
    streamr-docker-dev start
    streamr-docker-dev stop tracker
    streamr-docker-dev start --except tracker --wait
    streamr-docker-dev log -f tracker
    streamr-docker-dev shell tracker
    streamr-docker-dev pull

Options:
    --dry-run           echo commands instead of executing them

Show command-specific options:
	streamr-docker-dev help <command>
"
}

start_help() {
echo "
Starts the given services, or all services if none are specified.

Usage: streamr-docker-dev start [--] <service>...

Examples:
    streamr-docker-dev start
    streamr-docker-dev start tracker ganache
    streamr-docker-dev start --except tracker --wait

Options:
    --except [service]      start services except the one given
    --wait                  after starting, wait for services to become healthy (same as 'wait' command)
    --attached              start in attached mode
"
}

stop_help() {
echo "
Stops the given services, or all services if none are specified.

Usage: streamr-docker-dev stop [options] [--] <service>...

Examples:
    streamr-docker-dev stop
    streamr-docker-dev stop tracker ganache
"
}

restart_help() {
echo "
Restarts the given services, or all services if none are specified

Usage: streamr-docker-dev restart [options] [--] <service>...

Examples:
    streamr-docker-dev restart
    streamr-docker-dev restart tracker ganache
"
}

wait_help() {
echo "
Waits until pending health checks pass. Ignores services without health checks.

Usage: streamr-docker-dev wait [options]

Examples:
    streamr-docker-dev wait
    streamr-docker-dev wait --timeout 300

Options:
    --timeout [sec]      Sets the maximum time to wait. Default: 300 sec
"
}

ps_help() {
echo "
Shows currently running services. If no services given, shows all

Usage: streamr-docker-dev ps [<service>...]

Examples:
    streamr-docker-dev ps
    streamr-docker-dev ps tracker
"
}

log_help() {
echo "
Shows the logs of the given services

Usage: streamr-docker-dev log [[options] [--] <service>...]

Examples:
    streamr-docker-dev log
    streamr-docker-dev log tracker ganache
    streamr-docker-dev log -f tracker ganache

Options:
    -f --follow        	    follow log in realtime
"
}

shell_help() {
echo "
Opens an interactive shell into the target container.

Usage: streamr-docker-dev shell <service>

Examples:
    streamr-docker-dev shell tracker
"
}

pull_help() {
echo "
Pulls images defined in docker-compose files. If no services are given, pulls all of them.

Usage: streamr-docker-dev pull [ [--] <service>...]

Examples:
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
    "" )
        common_help
        ;;
    "start" )
        start_help
        ;;
    "stop" )
        stop_help
        ;;
    "restart" )
        restart_help
        ;;
    "wait" )
        wait_help
        ;;
    "ps" )
        ps_help
        ;;
    "log" )
        log_help
        ;;
    "shell" )
        shell_help
        ;;
    "pull" )
        pull_help
        ;;
    "wipe" )
        wipe_help
        ;;
    "factory-reset" )
        factory-reset_help
        ;;
    * ) common_help
        echo "ERROR: No help available for invalid command: $1"
        exit 1
        ;;
esac
