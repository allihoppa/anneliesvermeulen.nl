
DOCKER_IMAGE := allihoppa/anneliesvermeulen-nl-web
DOCKER_SWARM_HOST=lucasvanlierop-website
DOCKER_SWARM_STACK=anneliesvermeulen-website
export COMPOSE_PROJECT_NAME=anneliesvermeulen-website
DOCKER_COMPOSE_FILE_PROD=docker/environment/production/docker-compose.yml
DOCKER_COMPOSE_FILE_CI=docker/environment/ci/docker-compose.yml
DOCKER_DEPLOY_USER=deploy
DOCKER_DEPLOY_TAG=$(shell git show -s --format="%cI-%h" | sed -e 's/[:+]/-/g')
export DOCKER_IMAGE_AND_TAG := $(DOCKER_IMAGE):$(DOCKER_DEPLOY_TAG)
DOCKER_MANAGER_HOST=lucasvanlierop.nl
DOCKER_DEPLOY_SSH_TUNNEL=docker_manager_ssh_tunnel
DOCKER_DEPLOY_PORT=12374

.DEFAULT_GOAL: build
build: \
	docker/service/web/dist/.built
	test

docker/service/web/dist/.built: \
	docker/service/web/dist/Dockerfile \
	$(shell find public/)
	docker build \
		-f docker/service/web/dist/Dockerfile \
		-t $(DOCKER_IMAGE):latest \
		.
	touch $@

.PHONY: up
up: docker-tag
	docker-compose \
		-f docker/environment/development/docker-compose.yml \
		up

.PHONY: docker-tag
docker-tag: docker/service/web/dist/.built
	docker tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE_AND_TAG)


.PHONY: test
test: docker-tag
	docker-compose -f $(DOCKER_COMPOSE_FILE_CI) up -d
	tests/smoke-test.sh
	tests/validate-html.sh
	docker-compose -f $(DOCKER_COMPOSE_FILE_CI) stop

.PHONY: latest
publish: docker-tag

	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE_AND_TAG)

.PHONY: deploy
.ONESHELL: deploy
deploy: publish
	# Create SSH tunnel to Docker Swarm cluster
	docker run \
		-d \
		--name $(DOCKER_DEPLOY_SSH_TUNNEL) \
		-p $(DOCKER_DEPLOY_PORT):$(DOCKER_DEPLOY_PORT) \
		-v $(SSH_AUTH_SOCK):/ssh-agent \
		kingsquare/tunnel \
		*:$(DOCKER_DEPLOY_PORT):/var/run/docker.sock \
		$(DOCKER_DEPLOY_USER)@$(DOCKER_MANAGER_HOST)

	# Wait until tunnel is available
	docker/bin/wait-for-deploy-tunnel localhost:$(DOCKER_DEPLOY_PORT)

	# Deploy
	docker \
		-H localhost:$(DOCKER_DEPLOY_PORT) \
		stack deploy \
		--with-registry-auth \
		-c $(DOCKER_COMPOSE_FILE_PROD) \
		--prune \
		$(DOCKER_SWARM_STACK)

	# Close tunnel
	docker stop $(DOCKER_DEPLOY_SSH_TUNNEL)
	docker rm $(DOCKER_DEPLOY_SSH_TUNNEL)
