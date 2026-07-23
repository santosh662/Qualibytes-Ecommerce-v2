#!/usr/bin/env bash

set -e

bash monitoring/helm/install.sh

kubectl apply -f monitoring/

echo "Waiting..."

sleep 20

kubectl get pods -n monitoring

echo "Monitoring Ready"