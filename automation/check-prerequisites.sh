#!/bin/bash

set -e

echo "Checking Prerequisites..."

commands=("docker" "kubectl" "kind")

for cmd in "${commands[@]}"; do
    if command -v $cmd >/dev/null 2>&1
    then
        echo "✔ $cmd Installed"
    else
        echo "✘ $cmd Not Installed"
        exit 1
    fi
done

echo ""
echo "All dependencies are installed."