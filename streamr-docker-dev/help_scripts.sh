#!/usr/bin/env bash

common_help() {
echo "
streamr-docker-dev – Streamr Docker Developer Environment.

Usage: streamr-docker-dev [<command> [options] [--] <service>...]
    streamr-docker-dev
    streamr-docker-dev start --all
    streamr-docker-dev stop -r broker data-api
    streamr-docker-dev restart 1

Commands:
    help                show this screen
    start               start services
    stop                stop services
    restart             stop and start services 
    ps                  list docker containers
    bind-ip             attach (unused) IP address 10.200.10.1 to network interface lo0 on macOS details
    log                 show logs
    pull                pulls images

Options:
    -h --help           command help
    --dry-run   

Show command-spesific options:
	streamr-docker-dev <command> -h               
"
}

start_help() {
echo "
Starts the given services

Usage: streamr-docker-dev start [options] [--] <service>...
    streamr-docker-dev start --all
    streamr-docker-dev start broker data-api

Options:
    -a --all           apply to all services         
"
}

stop_help() {
echo "
Stops the given services

Usage: streamr-docker-dev stop [options] [--] <service>...
    streamr-docker-dev stop --all
    streamr-docker-dev stop broker data-api
    streamr-docker-dev stop -r broker data-api

Options:
    -a --all        	    apply to all services
    -r --remove-data    	remove persistent data      	
"
}

restart_help() {
echo "
Restarts the given services

Usage: streamr-docker-dev restart [options] [--] <service>...
    streamr-docker-dev restart --all
    streamr-docker-dev restart broker data-api
    streamr-docker-dev restart -r -k broker data-api

Options:
    -a --all        	    apply both stop and start to all services
    -r --remove-data    	remove persistent data
    -k --kill-all			apply stop to all services (does nothing with --all)      	
"
}

ps_help() {
echo "
Shows current services. If no services given, shows all

Usage: streamr-docker-dev ps [<service>...]
    streamr-docker-dev ps
    streamr-docker-dev ps broker data-api
"
}

bind_ip_help() {
echo "
Attach (unused) IP address 10.200.10.1 to network interface lo0 on macOS details
More info in https://docs.docker.com/docker-for-mac/networking/#use-cases-and-workarounds

Usage: streamr-docker-dev bind-ip
"
}

log_help() {
echo "
Shows the logs of the given services

Usage: streamr-docker-dev log [[options] [--] <service>...]
    streamr-docker-dev log
    streamr-docker-dev log broker data-api
    streamr-docker-dev log -f broker data-api

Options:
    -f --follow        	    follow log in realtime     	
"
}

pull_help() {
echo "
Pulls images defined in docker-compose files

Usage: streamr-docker-dev pull [ [--] <service>...]
    streamr-docker-dev pull --all
    streamr-docker-dev pull broker ganache
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
    "ps" )
        ps_help
        ;;
    "bind-ip" )
        bind_ip_help
        ;;
    "log" )
        log_help
        ;;
    "pull" )
        pull_help
        ;;
    * ) common_help
        ;;
esac
