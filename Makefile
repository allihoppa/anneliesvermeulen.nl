DOCKER_DEPLOY_TAG=$(shell git show -s --format="%cI-%h" | sed -e 's/[:+]/-/g')
DOCKER_IMAGE := allihoppa/anneliesvermeulen-nl-web
DOCKER_IMAGE_AND_TAG := $(DOCKER_IMAGE):$(DOCKER_DEPLOY_TAG)

.DEFAULT_GOAL: all

all: docker/service/web/dist/.built publish

docker/service/web/dist/.built: public/*
	docker build -t $(DOCKER_IMAGE_AND_TAG) -f docker/service/web/dist/Dockerfile .
	touch $@

.PHONY: up
up: docker/service/web/dist/.built
	set -x
	docker run --rm --name anneliesvermeulen-nl-web-dev -v $(shell pwd)/public:/usr/share/nginx/html -p 1090:80 $(DOCKER_IMAGE_AND_TAG)

.PHONY: latest
publish:
	docker push $(DOCKER_IMAGE_AND_TAG)
