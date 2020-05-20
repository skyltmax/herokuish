NAME = herokuish
HARDWARE = $(shell uname -m)
VERSION ?= 0.5.13
IMAGE_NAME ?= $(NAME)
BUILD_TAG ?= dev

BUILDPACK_ORDER := multi ruby nodejs clojure python java gradle scala play php go static
SHELL := /bin/bash

shellcheck:
ifneq ($(shell shellcheck --version > /dev/null 2>&1 ; echo $$?),0)
ifeq ($(SYSTEM),Darwin)
	brew install shellcheck
else
	@sudo add-apt-repository 'deb http://archive.ubuntu.com/ubuntu trusty-backports main restricted universe multiverse'
	@sudo apt-get update && sudo apt-get install -y shellcheck
endif
endif

build:
	@count=0; \
	for i in $(BUILDPACK_ORDER); do \
		bp_count=$$(printf '%02d' $$count) ; \
		echo -n "$${bp_count}_buildpack-$$i "; \
		cat buildpacks/*-$$i/buildpack* | sed 'N;s/\n/ /'; \
		count=$$((count + 1)) ; \
	done > include/buildpacks.txt
	go-bindata include
	mkdir -p build/linux  && GOOS=linux  go build -a -ldflags "-X main.Version=$(VERSION)" -o build/linux/$(NAME)
	mkdir -p build/darwin && GOOS=darwin go build -a -ldflags "-X main.Version=$(VERSION)" -o build/darwin/$(NAME)
	docker build -t $(IMAGE_NAME):$(BUILD_TAG) .
	docker build -f Dockerfile.build -t $(IMAGE_NAME):$(BUILD_TAG)-build .

clean:
	rm -rf build/*
	docker rm $(shell docker ps -aq) || true
	docker rmi herokuish:dev || true

deps:
	docker pull heroku/heroku:18
	docker pull heroku/heroku:18-build
	go get -u github.com/jteeuwen/go-bindata/...
	go get -u github.com/progrium/basht/...
	go get || true

test:
	basht tests/*/tests.sh

lint:
	# SC2002: Useless cat - https://github.com/koalaman/shellcheck/wiki/SC2002
	# SC2030: Modification of name is local - https://github.com/koalaman/shellcheck/wiki/SC2030
	# SC2031: Modification of name is local - https://github.com/koalaman/shellcheck/wiki/SC2031
	# SC2034: VAR appears unused - https://github.com/koalaman/shellcheck/wiki/SC2034
	@echo linting...
	shellcheck -e SC2002,SC2030,SC2031,SC2034 -s bash include/*.bash tests/**/tests.sh

.PHONY: build
