
DOCKER_IMAGE := allihoppa/anneliesvermeulen-nl-web
DOCKER_DEPLOY_TAG=$(shell git show -s --format="%cI-%h" | sed -e 's/[:+]/-/g')
export DOCKER_IMAGE_AND_TAG := $(DOCKER_IMAGE):$(DOCKER_DEPLOY_TAG)

.DEFAULT_GOAL: build

build: docker/service/web/dist/.built

docker/service/web/dist/.built: \
	docker/service/web/dist/Dockerfile \
	$(shell find public/)
	docker build \
		-f docker/service/web/dist/Dockerfile \
		-t $(DOCKER_IMAGE):latest \
		.
	touch $@

.PHONY: up
up: docker/service/web/dist/.built
	docker-compose \
		-f docker/environment/development/docker-compose.yml \
		up

.PHONY: latest
publish: docker/service/web/dist/.built
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE_AND_TAG)
	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE_AND_TAG)
