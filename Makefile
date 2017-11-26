.PHONY: dist
dist:
	docker build -t allihoppa/anneliesvermeulen.nl -f docker/service/web/dist/Dockerfile .

.PHONY: up
up:
	docker run --rm --name anneliesvermeulen.nl -v $(pwd)/public:/usr/share/nginx/html -p 1090:80 allihoppa/anneliesvermeulen.nl
