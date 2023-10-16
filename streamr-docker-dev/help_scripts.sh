#!/usr/bin/env bash

common_help() {
echo "
streamr-docker-dev – Streamr Docker Developer Environment.

Usage: streamr-docker-dev [<command> [options] [--] <service>...]

Commands:
    help                show this screen
    start               start services
    stop                stop services
    services            list all services
    restart             stop and start services
    wait                wait for all health checks to pass
    ps                  list docker containers
    log                 show logs
    shell               shell into a container
    pull                pulls latest versions of images
    update              updates streamr-docker-dev by doing git pull
    wipe                wipes the data persisted by all services
    factory-reset       removes all docker images and generated files
                          (WARNING: this deletes ALL docker images on
			            your system and their state -
				    not just Streamr-related ones!)
Examples:
    streamr-docker-dev start
    streamr-docker-dev stop entry-point
    streamr-docker-dev start --except entry-point --wait
    streamr-docker-dev log -f entry-point
    streamr-docker-dev shell entry-point
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
    streamr-docker-dev start entry-point parity-node0
    streamr-docker-dev start --except entry-point --wait

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
    streamr-docker-dev stop entry-point parity-node0
"
}

restart_help() {
echo "
Restarts the given services, or all services if none are specified

Usage: streamr-docker-dev restart [options] [--] <service>...

Examples:
    streamr-docker-dev restart
    streamr-docker-dev restart entry-point parity-node0
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
    streamr-docker-dev ps entry-point
"
}

log_help() {
echo "
Shows the logs of the given services

Usage: streamr-docker-dev log [[options] [--] <service>...]

Examples:
    streamr-docker-dev log
    streamr-docker-dev log entry-point parity-node0
    streamr-docker-dev log -f entry-point parity-node0

Options:
    -f --follow        	    follow log in realtime
"
}

shell_help() {
echo "
Opens an interactive shell into the target container.

Usage: streamr-docker-dev shell <service>

Examples:
    streamr-docker-dev shell entry-point
"
}

pull_help() {
echo "
Pulls images defined in docker-compose files. If no services are given, pulls all of them.

Usage: streamr-docker-dev pull [ [--] <service>...]

Examples:
    streamr-docker-dev pull
    streamr-docker-dev pull entry-point parity-node0
"
}

update_help() {
echo "
Updates streamr-docker-dev to the latest version by doing a "git pull" in the streamr-docker-dev directory.

Usage: streamr-docker-dev update
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
Resets the environment by removing all persisted data and all Docker images.
Warning: this deletes ALL docker images on your system and their state -
not just Streamr-related ones!

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
"update" )
    update_help
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
