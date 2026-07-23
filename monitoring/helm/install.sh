#!/usr/bin/env bash

set -e

kubectl apply -f monitoring/namespace.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

echo "Installing kube-prometheus-stack..."

helm upgrade --install prometheus \
prometheus-community/kube-prometheus-stack \
-n monitoring \
-f monitoring/helm/prometheus-values.yaml

echo "Installing Loki..."

helm upgrade --install loki \
grafana/loki-stack \
-n monitoring \
-f monitoring/helm/loki-values.yaml

echo "Monitoring Installed."