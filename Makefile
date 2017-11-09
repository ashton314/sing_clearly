DOCKER_IMAGE_NAME=ashton314/sing_clearly
DOCKER_IMAGE_TAG=latest
DOCKER_NAME_TAG=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
HOST_PORT=3000
CONTAINER_PORT=3000

daemon:
	MOJO_LISTEN=http://*:$(HOST_PORT) carton exec sing_clearly/script/sing_clearly daemon

dev:
	MOJO_LISTEN=http://*:$(HOST_PORT) carton exec morbo ./sing_clearly/script/sing_clearly

# run the docker instance, remove when finished (hence the `--rm` flag)
run:
	docker run --rm -p $(HOST_PORT):$(CONTAINER_PORT) -d $(DOCKER_IMAGE_NAME)

build:
	docker build -t $(DOCKER_NAME_TAG) .

install:
	carton install
