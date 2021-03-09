# Variables
MAJOR_VERSION = 1
MINOR_VERSION = 0
PATCH_VERSION = 0
REVISION ?= $$(git rev-parse --short HEAD)
VERSION ?= $(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_VERSION)
TAG = $(VERSION).$(BUILD_NUMBER)-$(REVISION)

IMAGE_LABEL=pyspark_aws
AWS_REGION=us-east-1
AWS_ACCOUNT_ID = ${AWS_ACCOUNT}
DOCKER_REPO = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com

# Help / Self Documentation
.PHONY: help

help: ## Help command to see what commands are available and what they do
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST}${NO_COLOR}

.DEFAULT_GOAL := help

# Docker login if any
# docker-login:
# 	aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(DOCKER_REPO)

config-java: docker-login
	AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" aws s3 cp s3://location-to-jdk/jdk-8u161-linux-x64.tar.gz artifact/

# DOCKER TASKS
build: config-java ## Build the container
	docker build -t ${IMAGE_LABEL}:${TAG} .


## Docker push if any
# docker-push: docker-login ## Push the image to ECR
# 	aws ecr describe-repositories --repository-names ${IMAGE_LABEL}:$(TAG) --region ${AWS_REGION} \
# 		|| aws ecr create-repository --repository-name ${IMAGE_LABEL} --region ${AWS_REGION}
# 	docker tag ${IMAGE_LABEL}:${TAG} ${DOCKER_REPO}/${IMAGE_LABEL}:${TAG}
# 	docker push ${DOCKER_REPO}/${IMAGE_LABEL}:${TAG}

docker-run:
	docker run -it --rm pyspark_aws