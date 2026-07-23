#!/bin/bash

set -e

echo "Creating Kind Cluster..."

kind create cluster \
--name qualibytes \
--config kind/kind-config.yaml

echo "Cluster Created."