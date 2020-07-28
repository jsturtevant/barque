#!/usr/bin/env bash

set -e

ORIGIN_OVERRIDE=./scripts
TARGET_DIRECTORY=./.azuredevops/scripts

if [ -d "$ORIGIN_OVERRIDE" ]; then
    for file in $ORIGIN_OVERRIDE/*.sh; do
        echo "Overriding $file"
        ln $file -t $TARGET_DIRECTORY -f
    done
fi