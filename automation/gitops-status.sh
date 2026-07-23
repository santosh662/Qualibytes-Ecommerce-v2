#!/usr/bin/env bash

echo "Latest Image"

grep image: kubernetes/08-qbshop-deployment.yaml

echo ""

echo "ArgoCD Pods"

kubectl get pods -n argocd

echo ""

echo "Application"

kubectl get applications -n argocd