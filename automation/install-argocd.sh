#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Install ArgoCD
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Installing ArgoCD"

ARGO_NAMESPACE="argocd"
ARGO_APP="${PROJECT_ROOT}/kubernetes/argocd/application.yaml"

###############################################################################
# Create Namespace
###############################################################################

if namespace_exists "${ARGO_NAMESPACE}"
then
    success "ArgoCD namespace already exists."
else
    info "Creating ArgoCD namespace..."

    kubectl create namespace "${ARGO_NAMESPACE}"

    success "Namespace created."
fi

###############################################################################
# Install ArgoCD
###############################################################################

line

if deployment_exists "${ARGO_NAMESPACE}" "argocd-server"
then

    success "ArgoCD already installed."

else

    info "Installing ArgoCD..."
    retry 3 kubectl apply \
        --server-side \
        --force-conflicts \
        -n "${ARGO_NAMESPACE}" \
        -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
fi

###############################################################################
# Wait
###############################################################################

line

info "Waiting for ArgoCD Server..."

wait_deployment "${ARGO_NAMESPACE}" "argocd-server"

success "ArgoCD Server Ready."

###############################################################################
# Deploy Application
###############################################################################

line

if [[ -f "${ARGO_APP}" ]]
then

    info "Deploying ArgoCD Application..."

    retry 3 kubectl apply -f "${ARGO_APP}"

    success "Application Registered."

else

    warning "Application manifest not found."

fi

###############################################################################
# Display Resources
###############################################################################

line

kubectl get pods -n "${ARGO_NAMESPACE}"

###############################################################################
# Finish
###############################################################################

completed "ArgoCD Installation Completed."
