#!/bin/bash

set -e

echo "======================================"
echo "Loading Images into Kind"
echo "======================================"

kind load docker-image qualibytes-shop-app:local \
--name qualibytes

kind load docker-image qualibytes-shop-migration:local \
--name qualibytes

echo ""
echo "Images Loaded Successfully"