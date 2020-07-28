#!/usr/bin/env bash

set -e

az extension add --name azure-devops

git checkout -b $BUILD_SOURCEBRANCHNAME-pr-$BUILD_BUILDNUMBER
git commit -m "Update $ENV_PARAMS with $IMAGE_NAME" -m "from $BUILD_SOURCEBRANCHNAME commit from $BUILD_DEFINITIONNAME with buildId: $BUILD_BUILDID and buildNumber: $BUILD_BUILDNUMBER"
git push origin $BUILD_SOURCEBRANCHNAME-pr-$BUILD_BUILDNUMBER

echo ${AZURE_DEVOPS_CLI_PAT} | az devops login
az repos pr create --description "Update $ENV_PARAMS with $IMAGE_NAME from $BUILD_SOURCEBRANCHNAME commit from $BUILD_DEFINITIONNAME with buildId: $BUILD_BUILDID and buildNumber: $BUILD_BUILDNUMBER" "PR created by: $BUILD_DEFINITIONNAME with buildId: $BUILD_BUILDID and buildNumber: $BUILD_BUILDNUMBER"
