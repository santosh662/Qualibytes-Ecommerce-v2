#!/usr/bin/env bash

###############################################################################
# Qualibytes Bootstrap
# Installs all required dependencies for local Kubernetes development.
###############################################################################

set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

###############################################################################
# Colors
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

###############################################################################
# Logging Helpers
###############################################################################

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

trap 'error "Bootstrap failed at line $LINENO"' ERR

###############################################################################
# Banner
###############################################################################

echo
echo "====================================================="
echo "          Qualibytes Bootstrap"
echo "====================================================="
echo

###############################################################################
# Root Check
###############################################################################

if [[ $EUID -eq 0 ]]; then
    error "Run this script as normal user."
    exit 1
fi

###############################################################################
# Ubuntu Check
###############################################################################

if ! grep -qi ubuntu /etc/os-release; then
    error "Only Ubuntu is officially supported."
    exit 1
fi

###############################################################################
# Update Packages
###############################################################################

log "Updating package repositories..."

sudo apt-get update -y

###############################################################################
# Install Required Packages
###############################################################################

log "Installing required packages..."

sudo apt-get install -y \
curl \
wget \
git \
jq \
make \
unzip \
tar \
vim \
net-tools \
ca-certificates \
apt-transport-https \
gnupg \
lsb-release

success "Required packages installed."

###############################################################################
# Docker Installation
###############################################################################

if command -v docker >/dev/null 2>&1
then
    success "Docker already installed."
else

    log "Installing Docker..."

    curl -fsSL https://get.docker.com | sudo sh

    sudo systemctl enable docker

    sudo systemctl start docker

    success "Docker Installed."

fi

###############################################################################
# Start Docker
###############################################################################

sudo systemctl enable docker

sudo systemctl start docker

###############################################################################
# Docker Group
###############################################################################

if groups "$USER" | grep -qw docker
then
    success "User already belongs to docker group."
else

    log "Adding $USER to docker group..."

    sudo usermod -aG docker "$USER"

    warn "Docker group added."

    warn "You must logout/login once."

fi

###############################################################################
# Verify Docker Service
###############################################################################

if sudo systemctl is-active docker >/dev/null
then
    success "Docker Service Running."
else
    error "Docker Service Failed."
    exit 1
fi
###############################################################################
# kubectl Installation
###############################################################################

if command -v kubectl >/dev/null 2>&1
then
    success "kubectl already installed."
else

    log "Installing kubectl..."

    KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"

    curl -fsSL \
        "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
        -o /tmp/kubectl

    chmod +x /tmp/kubectl

    sudo install -m 755 /tmp/kubectl /usr/local/bin/kubectl

    rm -f /tmp/kubectl

    success "kubectl installed."

fi

###############################################################################
# Kind Installation
###############################################################################

if command -v kind >/dev/null 2>&1
then
    success "Kind already installed."
else

    log "Installing Kind..."

    curl -fsSL \
        https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 \
        -o /tmp/kind

    chmod +x /tmp/kind

    sudo install -m 755 /tmp/kind /usr/local/bin/kind

    rm -f /tmp/kind

    success "Kind installed."

fi

###############################################################################
# Helm Installation
###############################################################################

if command -v helm >/dev/null 2>&1
then
    success "Helm already installed."
else

    log "Installing Helm..."

    curl -fsSL \
        https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
        | bash

    success "Helm installed."

fi

###############################################################################
# Git Verification
###############################################################################

if command -v git >/dev/null 2>&1
then
    success "Git installed."
else
    error "Git installation failed."
    exit 1
fi

###############################################################################
# Verify Installed Versions
###############################################################################

echo
echo "====================================================="
echo "Installed Versions"
echo "====================================================="

docker --version || true

kubectl version --client

kind --version

helm version --short

git --version

make --version

echo
success "All required tools are available."

###############################################################################
# Docker Permission Check
###############################################################################

echo

if docker info >/dev/null 2>&1
then

    success "Docker permission verified."

    echo
    success "Bootstrap completed successfully."
    echo
    echo "Run:"
    echo
    echo "    make start"
    echo

else

    warn "Docker group has been configured."

    echo
    warn "Logout/Login (or run newgrp docker)"
    warn "Then execute:"
    echo
    echo "    make start"
    echo

fi

echo "====================================================="
