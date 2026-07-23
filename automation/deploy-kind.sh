#!/usr/bin/env bash

set -euo pipefail

echo "========================================="
echo "Deploying Application"
echo "========================================="

kubectl apply -f kubernetes/

echo ""
echo "Deployment Applied."