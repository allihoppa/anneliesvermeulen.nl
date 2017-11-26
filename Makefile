.DEFAULT_GOAL: docker/service/web/dist/.built
docker/service/web/dist/.built: public/*
	docker build -t allihoppa/anneliesvermeulen.nl -f docker/service/web/dist/Dockerfile .
	touch $@

.PHONY: up
up: docker/service/web/dist/.built
	set -x
	docker run --rm --name anneliesvermeulen.nl -v $(shell pwd)/public:/usr/share/nginx/html -p 1090:80 allihoppa/anneliesvermeulen.nl
