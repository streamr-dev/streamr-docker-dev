#
# https://makefiletutorial.com
# https://clarkgrubb.com/makefile-style-guide
#

LANG := en_US.UTF-8
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c # run '/bin/bash ... -c /bin/cmd'
.DEFAULT_GOAL := test-smoke

YAMLLINT := /usr/local/bin/yamllint
YAMLLINTFLAGS := --config-file yamllint-config.yaml

COMPOSE := docker compose

$(YAMLLINT):
	pip3 install --user yamllint

.PHONY: lint-yaml
lint-yaml: $(YAMLLINT)
	$(YAMLLINT) $(YAMLLINTFLAGS) .

.PHONY: test-smoke
test-smoke:
	$(COMPOSE) -f docker-compose.yml -f docker-compose-ci.yml config

.PHONY: test-docker-dev
test-docker-dev:
	./streamr-docker-dev/bin.sh start --wait --except chainlink
	./streamr-docker-dev/bin.sh start chainlink &
	./streamr-docker-dev/bin.sh log -f chainlink &
	./streamr-docker-dev/bin.sh stop

