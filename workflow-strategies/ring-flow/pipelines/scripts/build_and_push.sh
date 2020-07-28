#!/usr/bin/env bash

set -e

# TODO this should be compiled once and shared across stages: https://github.com/microsoft/azure-pipelines-tasks/issues/4743
BUILD_REPO_NAME=$(echo $BUILD_REPOSITORY_NAME-$SERVICENAME | tr '[:upper:]' '[:lower:]')
IMAGE_NAME=$BUILD_REPO_NAME:$BUILD_SOURCEBRANCHNAME-$BUILD_SOURCEVERSION

# env get all-caps when passed in from pipeline
echo "az acr build -r $ACRNAME --image $IMAGE_NAME ."
az acr build -r $ACRNAME --image $IMAGE_NAME .
