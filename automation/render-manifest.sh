#!/usr/bin/env bash

source automation/load-env.sh

export IMAGE_TAG=${IMAGE_TAG:-latest}

envsubst \
< kubernetes/08-qbshop-deployment.yaml.template \
> kubernetes/08-qbshop-deployment.yaml