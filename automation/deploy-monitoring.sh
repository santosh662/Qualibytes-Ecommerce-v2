#!/usr/bin/env bash

source automation/versions.sh

set -euo pipefail

echo "========================================"
echo " Installing Monitoring Stack"
echo "========================================"


echo "Installing Helm Charts..."

bash monitoring/helm/install.sh


echo "Applying Monitoring Manifests..."

kubectl apply -k monitoring/


echo "Waiting for Monitoring Pods..."

sleep 30


kubectl get pods -n monitoring


echo ""
echo "Monitoring Installed Successfully"
