#!/usr/bin/env bash

set -euo pipefail

echo "Creating Kind Cluster..."

kind create cluster \
--name qualibytes \
--config kind/kind-config.yaml

echo "Installing Metrics Server..."
# (Phase-2)

echo "Installing Ingress..."
# (Phase-2)

echo "Cluster Ready."