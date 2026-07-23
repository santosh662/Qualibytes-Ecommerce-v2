#!/usr/bin/env bash

set -e

source config/common.env

TARGET="${TARGET:-kind}"

if [ "$TARGET" = "kind" ]; then
    source config/kind.env
else
    source config/eks.env
fi

export PROJECT_NAME
export CLUSTER_NAME
export NAMESPACE
export APP_IMAGE
export MIGRATION_IMAGE