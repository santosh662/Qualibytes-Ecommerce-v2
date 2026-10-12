#!/usr/bin/env bash

set -euo pipefail

IMAGE_TAG=${1}

echo "Updating deployment image to ${IMAGE_TAG}"

sed -i "s|image: mrsinghdev/qbshop-app:.*|image: mrsinghdev/qbshop-app:${IMAGE_TAG}|g" \
kubernetes/08-qbshop-deployment.yaml

sed -i "s|image: mrsinghdev/qbshop-migration:.*|image: mrsinghdev/qbshop-migration:${IMAGE_TAG}|g" \
kubernetes/12-migration-job.yaml

echo "Manifest Updated"