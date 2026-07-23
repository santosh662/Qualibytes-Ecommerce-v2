#!/usr/bin/env bash

set -e

source automation/load-env.sh

if [ "$TARGET" = "kind" ]; then

    echo "Loading image into Kind..."

    kind load docker-image ${DOCKER_USERNAME}/${APP_IMAGE}:latest \
    --name ${CLUSTER_NAME}

else

    echo "Image already pushed to DockerHub"

fi