#!/usr/bin/env bash

set -e

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply \
-n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo ""

echo "Waiting ArgoCD..."

kubectl wait \
--for=condition=Available \
deployment/argocd-server \
-n argocd \
--timeout=600s

kubectl apply -f kubernetes/argocd/application.yaml

echo ""

echo "ArgoCD Installed"