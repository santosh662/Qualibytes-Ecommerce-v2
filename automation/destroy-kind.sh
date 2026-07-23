#!/usr/bin/env bash

set -euo pipefail

echo "Deleting Application..."

kubectl delete -f kubernetes/ --ignore-not-found=true

echo "Done."