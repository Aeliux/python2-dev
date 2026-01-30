.PHONY: help build build-no-cache test push clean shell run

# Variables
IMAGE_NAME ?= python2-dev
IMAGE_TAG ?= 2.7.18
IMAGE_LATEST ?= latest
DEBIAN_VERSION ?= trixie
REGISTRY ?= docker.io
USERNAME ?= aeliux
FULL_IMAGE_NAME = $(REGISTRY)/$(USERNAME)/$(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION)
FULL_IMAGE_LATEST = $(REGISTRY)/$(USERNAME)/$(IMAGE_NAME):$(IMAGE_LATEST)

help: ## Show this help message
	@echo "Python 2.7.18 Development Environment - Make targets"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Docker image
	@echo "Building $(FULL_IMAGE_NAME)..."
	DOCKER_BUILDKIT=1 docker build \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--tag $(FULL_IMAGE_NAME) \
		--tag $(FULL_IMAGE_LATEST) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION) \
		--file Dockerfile \
		.

build-no-cache: ## Build the Docker image without cache
	@echo "Building $(FULL_IMAGE_NAME) without cache..."
	DOCKER_BUILDKIT=1 docker build \
		--no-cache \
		--build-arg DEBIAN_VERSION=$(DEBIAN_VERSION) \
		--tag $(FULL_IMAGE_NAME) \
		--tag $(FULL_IMAGE_LATEST) \
		--tag $(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION) \
		--file Dockerfile \
		.

test: ## Test the built image-$(DEBIAN_VERSION) python2 --version
	@echo "Testing pip installation..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION) pip --version
	@echo "Testing user permissions..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION) whoami
	@echo "Testing installed packages..."
	@docker run --rm $(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION) pip list
	@echo "All tests passed!"

shell: ## Run interactive shell in container
	docker run -it --rm \
		-v $(PWD)/../:/workspace \
		$(IMAGE_NAME):$(IMAGE_TAG)-$(DEBIAN_VERSION
		-v $(PWD)/../:/workspace \
		$(IMAGE_NAME):$(IMAGE_TAG) bash

run: ## Run the container
	docker run -it --rm \
		-v $(PWD)/../:/workspace \
		$(IMAGE_NAME):$(IMAGE_TAG)

push: ## Push image to registry
	@echo "Pushing $(FULL_IMAGE_NAME)..."
	docker push $(FULL_IMAGE_NAME)
	@echo "Pushing $(FULL_IMAGE_LATEST)..."
	docker push $(FULL_IMAGE_LATEST)

login: ## Login to Docker registry
	docker login $(REGISTRY)

size: ## Show image size
	@docker images $(IMAGE_NAME):$(IMAGE_TAG) --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

inspect: ## Inspect image metadata
	@docker inspect $(IMAGE_NAME):$(IMAGE_TAG) | jq '.[0].Config.Labels'

clean: ## Remove built images
	@echo "Removing local images..."
	-docker rmi $(IMAGE_NAME):$(IMAGE_TAG)
	-docker rmi $(FULL_IMAGE_NAME)
	-docker rmi $(FULL_IMAGE_LATEST)
	@echo "Cleaning up dangling images..."
	-docker image prune -f

clean-all: clean ## Remove all images and build cache
	@echo "Removing build cache..."
	docker builder prune -f

# Example usage:
# make build
# make test
# make push REGISTRY=docker.io USERNAME=yourusername
