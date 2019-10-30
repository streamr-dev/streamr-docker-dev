#!/bin/bash

streamr-docker-dev stop --all -r
docker rmi -f $(docker images -aq)
streamr-docker-dev start 5

