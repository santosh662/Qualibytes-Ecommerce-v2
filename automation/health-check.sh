#!/usr/bin/env bash

set -euo pipefail

echo "Checking MongoDB..."
kubectl rollout status statefulset/mongodb -n qbshop --timeout=300s

echo "Checking Application..."
kubectl rollout status deployment/qbshop -n qbshop --timeout=300s

echo "Checking Ingress..."
kubectl wait \
--namespace ingress-nginx \
--for=condition=Ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=300s

echo "Checking Monitoring..."
kubectl wait \
--namespace monitoring \
--for=condition=Ready pod \
--all \
--timeout=300s

echo ""
echo "All Services are Healthy"