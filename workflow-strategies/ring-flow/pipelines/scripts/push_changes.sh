#!/usr/bin/env bash

set -e

git checkout master

# needs permissions on Project Collection Build Service Accounts https://developercommunity.visualstudio.com/content/problem/137489/0000000000aatf401027-genericcontribute-permissions.html
git commit -m "Update $ENV_PARAMS with $IMAGE_NAME" -m "from $BUILD_SOURCEBRANCHNAME commit from $BUILD_DEFINITIONS with buildId: $BUILD_BUILDID and buildNumber: $BUILD_BUILDNUMBER" || true
git status
git push origin master || true
