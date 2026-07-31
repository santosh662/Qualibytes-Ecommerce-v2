#!/usr/bin/env bash

set -euo pipefail

source automation/versions.sh

echo "======================================"
echo " Installing Monitoring Stack"
echo "======================================"

# Create Namespace
kubectl apply -f monitoring/namespace.yaml

# Add Helm Repositories
echo "Adding Helm Repositories..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true

echo "Updating Helm Repositories..."
helm repo update

########################################
# Install Prometheus Stack
########################################

echo "Installing Prometheus..."

helm upgrade --install prometheus \
  prometheus-community/kube-prometheus-stack \
  --version ${PROMETHEUS_CHART_VERSION} \
  -n monitoring \
  --create-namespace \
  -f monitoring/helm/prometheus-values.yaml \
  --wait

########################################
# Install Loki
########################################

echo "Installing Loki..."

helm upgrade --install loki \
  grafana/loki \
  --version ${LOKI_CHART_VERSION} \
  -n monitoring \
  -f monitoring/helm/loki-values.yaml \
  --wait


###########################################
# Install promtail
# #########################################
helm upgrade --install promtail \
  grafana/promtail \
  --version ${PROMTAIL_CHART_VERSION} \
  -n monitoring \
  -f monitoring/helm/promtail-values.yaml \
  --wait

echo ""
echo "======================================"
echo " Monitoring Installed Successfully"
echo "======================================"
