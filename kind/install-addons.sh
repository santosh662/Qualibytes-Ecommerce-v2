#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Install Kubernetes Addons
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${PROJECT_ROOT}/automation/common.sh"

###############################################################################
# NGINX Ingress
###############################################################################

banner "Installing NGINX Ingress Controller"

if deployment_exists ingress-nginx ingress-nginx-controller
then

    success "NGINX Ingress already installed."

else

    info "Installing NGINX Ingress..."

    retry 3 \
    kubectl apply -f \
    https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

fi

line

info "Waiting for Ingress Controller..."

wait_deployment ingress-nginx ingress-nginx-controller

success "NGINX Ingress Ready."

###############################################################################
# Metrics Server
###############################################################################

banner "Installing Metrics Server"

if deployment_exists kube-system metrics-server
then

    success "Metrics Server already installed."

else

    info "Installing Metrics Server..."

    retry 3 \
    kubectl apply -f \
    https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

fi

###############################################################################
# Patch Metrics Server
###############################################################################

line

info "Configuring Metrics Server..."

kubectl patch deployment metrics-server \
-n kube-system \
--type=json \
-p='[
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"},
{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-preferred-address-types=InternalIP"}
]' >/dev/null 2>&1 || true

###############################################################################
# Wait
###############################################################################

line

info "Waiting for Metrics Server..."

wait_deployment kube-system metrics-server

success "Metrics Server Ready."

###############################################################################
# Verification
###############################################################################

line

info "Checking Metrics API..."

kubectl top nodes >/dev/null 2>&1 || true

kubectl top pods -A >/dev/null 2>&1 || true

success "Metrics API Verified."


echo "========================================"
echo " Installing Cert Manager"
echo "========================================"

if kubectl get deployment cert-manager -n cert-manager >/dev/null 2>&1
then
    echo "Cert Manager already installed."
else

    kubectl apply -f \
    https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

fi


echo "Waiting for Cert Manager..."

kubectl wait \
--for=condition=Available \
deployment/cert-manager \
-n cert-manager \
--timeout=300s


echo "Cert Manager Ready."

###############################################################################
# Finish
###############################################################################

completed "All Kubernetes Addons Installed."
