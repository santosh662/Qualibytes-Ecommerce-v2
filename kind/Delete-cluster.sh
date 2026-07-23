#!/bin/bash

set -e

echo "Deleting Kind Cluster..."

kind delete cluster --name qualibytes

echo "Cluster Deleted."