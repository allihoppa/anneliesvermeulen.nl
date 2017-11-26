.DEFAULT_GOAL: docker/service/web/dist/.built
docker/service/web/dist/.built: public/*
	docker build -t allihoppa/anneliesvermeulen.nl -f docker/service/web/dist/Dockerfile .
	touch $@

.PHONY: up
up: docker/service/web/dist/.built
	docker run --rm --name anneliesvermeulen.nl -v $(pwd)/public:/usr/share/nginx/html -p 1090:80 allihoppa/anneliesvermeulen.nl
