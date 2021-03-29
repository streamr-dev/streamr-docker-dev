#
# https://makefiletutorial.com
# https://clarkgrubb.com/makefile-style-guide
#

LANG := en_US.UTF-8
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # run '/bin/bash ... -c /bin/cmd'
.DEFAULT_GOAL := test-smoke

.PHONY: test-smoke
test-smoke:
	docker-compose -f docker-compose.yml config

