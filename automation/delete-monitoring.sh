#!/usr/bin/env bash

set -e

bash monitoring/helm/uninstall.sh

echo "Removing Monitoring..."

kubectl delete -f monitoring/ \
--ignore-not-found=true

echo "Monitoring Removed"