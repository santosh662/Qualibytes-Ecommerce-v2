#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Create Kind Cluster
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Creating Kind Kubernetes Cluster"

###############################################################################
# Configuration
###############################################################################

CLUSTER_NAME="qualibytes"
KIND_CONFIG="${PROJECT_ROOT}/kind/kind-config.yml"

###############################################################################
# Verify Config File
###############################################################################

if [[ ! -f "${KIND_CONFIG}" ]]
then
    error "Kind configuration file not found."
    echo
    echo "Expected:"
    echo "    ${KIND_CONFIG}"
    echo
    exit 1
fi

###############################################################################
# Cluster Exists
###############################################################################

if kind_cluster_exists
then
    success "Kind cluster already exists."

    echo
    info "Using existing cluster..."
    echo

else

    info "Creating Kind Cluster..."

    retry 3 \
    kind create cluster \
        --name "${CLUSTER_NAME}" \
        --config "${KIND_CONFIG}"

fi

###############################################################################
# Wait for Cluster
###############################################################################

line

info "Waiting for Kubernetes API..."

COUNT=0

until kubectl cluster-info >/dev/null 2>&1
do

    COUNT=$((COUNT+1))

    if [[ $COUNT -gt 30 ]]
    then
        error "Cluster failed to become ready."
        exit 1
    fi

    sleep 5

done

success "Kubernetes API Ready."

###############################################################################
# Verify Nodes
###############################################################################

line

info "Checking Nodes..."

kubectl get nodes

NODE_COUNT=$(kubectl get nodes --no-headers | wc -l)

if [[ "$NODE_COUNT" -lt 1 ]]
then

    error "No Kubernetes nodes detected."

    exit 1

fi

success "${NODE_COUNT} Node(s) Available."

###############################################################################
# Verify System Pods
###############################################################################

line

info "Waiting for CoreDNS..."

kubectl rollout status deployment/coredns \
    -n kube-system \
    --timeout=300s

success "CoreDNS Ready."

###############################################################################
# Verify Cluster
###############################################################################

line

kubectl cluster-info

###############################################################################
# Finish
###############################################################################

completed "Kind Cluster Ready."
