#!/usr/bin/env bash

set -e

echo "======================================"
echo " Qualibytes Bootstrap"
echo "======================================"

sudo apt-get update

echo "Installing packages..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    make \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

##############################################
# Docker
##############################################

if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."

    curl -fsSL https://get.docker.com | sudo sh

    sudo systemctl enable docker
    sudo systemctl start docker

    sudo usermod -aG docker $USER
else
    echo "Docker already installed"
fi

##############################################
# kubectl
##############################################

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing kubectl..."

    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

    chmod +x kubectl

    sudo mv kubectl /usr/local/bin/
else
    echo "kubectl already installed"
fi

##############################################
# Kind
##############################################

if ! command -v kind >/dev/null 2>&1; then
    echo "Installing Kind..."

    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64

    chmod +x kind

    sudo mv kind /usr/local/bin/
else
    echo "Kind already installed"
fi

##############################################
# Helm
##############################################

if ! command -v helm >/dev/null 2>&1; then
    echo "Installing Helm..."

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm already installed"
fi

##############################################
# Verify
##############################################

echo ""
echo "========== Installed Versions =========="

docker --version
kubectl version --client
kind --version
helm version --short
git --version
make --version

echo ""
echo "======================================"
echo " Bootstrap Completed"
echo " Please logout/login once"
echo " OR run:"
echo ""
echo " newgrp docker"
echo ""
echo "Then execute:"
echo ""
echo " make start"
echo "======================================"

