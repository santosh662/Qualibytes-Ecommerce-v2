#!/usr/bin/env bash

set -euo pipefail

echo ""
echo "============================="
echo " Kubernetes Nodes"
echo "============================="

kubectl get nodes

echo ""

echo "============================="
echo " Pods"
echo "============================="

kubectl get pods -A

echo ""

echo "============================="
echo " Services"
echo "============================="

kubectl get svc -A

echo ""

echo "============================="
echo " Ingress"
echo "============================="

kubectl get ingress -A

echo ""

echo "Environment Ready"