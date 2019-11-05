#!/bin/bash

streamr-docker-dev stop --all -r
docker system prune --all --force --volumes
streamr-docker-dev start 5

