#!/usr/bin/env bash

set -euo pipefail

echo "========================================"
echo " Installing NGINX Ingress Controller"
echo "========================================"

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress Controller..."

kubectl wait \
--namespace ingress-nginx \
--for=condition=Ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=300s

echo "========================================"
echo " Installing Metrics Server"
echo "========================================"

kubectl apply -f \
https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

sleep 10

kubectl patch deployment metrics-server \
-n kube-system \
--type=json \
-p='[
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"},
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-preferred-address-types=InternalIP"}
]'

kubectl rollout status deployment metrics-server -n kube-system

echo ""
echo "Addons Installed Successfully"