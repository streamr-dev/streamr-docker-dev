#
# https://makefiletutorial.com
# https://clarkgrubb.com/makefile-style-guide
#

LANG := en_US.UTF-8
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c # run '/bin/bash ... -c /bin/cmd'
.DEFAULT_GOAL := test-smoke

.PHONY: test-smoke
test-smoke:
	docker-compose -f docker-compose.yml config

.PHONY: test-docker-dev
test-docker-dev:
	./streamr-docker-dev/bin.sh start --wait
	./streamr-docker-dev/bin.sh stop

