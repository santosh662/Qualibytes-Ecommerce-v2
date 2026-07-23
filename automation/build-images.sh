#!/bin/bash

set -e

echo "======================================"
echo "Building Docker Images"
echo "======================================"

echo ""
echo "Building Application Image..."

docker build \
-t qualibytes-shop-app:local \
-f Dockerfile .

echo ""
echo "Building Migration Image..."

docker build \
-t qualibytes-shop-migration:local \
-f scripts/Dockerfile.migration .

echo ""
echo "Docker Images Built Successfully"