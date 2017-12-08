
DOCKER_IMAGE := allihoppa/anneliesvermeulen-nl-web
DOCKER_DEPLOY_TAG=$(shell git show -s --format="%cI-%h" | sed -e 's/[:+]/-/g')
export DOCKER_IMAGE_AND_TAG := $(DOCKER_IMAGE):$(DOCKER_DEPLOY_TAG)

.DEFAULT_GOAL: all

all: docker/service/web/dist/.built publish

docker/service/web/dist/.built: public/*
	docker build -t $(DOCKER_IMAGE_AND_TAG) -f docker/service/web/dist/Dockerfile .
	touch $@

.PHONY: up
up: docker/service/web/dist/.built
	docker-compose \
		-f docker/environment/development/docker-compose.yml \
		up

.PHONY: latest
publish:
	docker push $(DOCKER_IMAGE_AND_TAG)
