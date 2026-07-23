#!/usr/bin/env bash

set -e

source automation/load-env.sh

echo "Deploying to EKS..."

kubectl apply -f kubernetes/

kubectl rollout status deployment/qbshop -n qbshop

echo "Deployment Successful"