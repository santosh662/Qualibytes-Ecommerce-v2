#!/usr/bin/env bash

echo ""

echo "Application"

echo "http://localhost"

echo ""

echo "ArgoCD"

kubectl port-forward svc/argocd-server \
-n argocd \
8080:443