.PHONY: build
build:
		go build -v ./cmd/apiserver


.PHONY: test
test:
		go test -v -race -timeout 30s ./...


.PHONY: docker-build
docker-build:
		docker build -t restapi:latest .


.PHONY: docker-up
docker-up:
		docker-compose up -d


.PHONY: docker-down
docker-down:
		docker-compose down


.PHONY: docker-logs
docker-logs:
		docker-compose logs -f api


.PHONY: docker-rebuild
docker-rebuild:
		docker-compose up -d --build


.DEFAULT_GOAL := build