#!/usr/bin/env bash

set -euo pipefail

echo "Deleting Kind Cluster..."

kind delete cluster --name qualibytes

echo "Done."