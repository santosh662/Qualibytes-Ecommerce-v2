#!/usr/bin/env bash

set -Eeuo pipefail

echo "========================================"
echo " Installing NGINX Ingress Controller"
echo "========================================"

if kubectl get deployment ingress-nginx-controller -n ingress-nginx >/dev/null 2>&1; then
    echo "Ingress Controller already installed."
else
    kubectl apply -f \
    https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
fi

echo "Waiting for Ingress Controller..."

kubectl rollout status deployment/ingress-nginx-controller \
-n ingress-nginx \
--timeout=300s

echo "========================================"
echo " Installing Metrics Server"
echo "========================================"

if kubectl get deployment metrics-server -n kube-system >/dev/null 2>&1; then
    echo "Metrics Server already installed."
else
    kubectl apply -f \
    https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
fi

kubectl patch deployment metrics-server \
-n kube-system \
--type=json \
-p='[
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"},
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-preferred-address-types=InternalIP"}
]' || true

kubectl rollout status deployment metrics-server -n kube-system --timeout=300s
