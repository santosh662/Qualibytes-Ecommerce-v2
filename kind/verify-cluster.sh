#!/usr/bin/env bash

set -euo pipefail

echo "Checking Cluster..."

kubectl cluster-info

kubectl get nodes

kubectl get pods -A