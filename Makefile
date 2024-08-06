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

$(YAMLLINT):
	pip3 install --user yamllint

.PHONY: lint-yaml
lint-yaml: $(YAMLLINT)
	$(YAMLLINT) $(YAMLLINTFLAGS) .

.PHONY: test-smoke
test-smoke:
	docker compose -f docker-compose.yml -f docker-compose-ci.yml config
