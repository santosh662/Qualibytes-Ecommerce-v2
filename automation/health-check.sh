#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Health Check
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Running Platform Health Check"

APP_NAMESPACE="qbshop"
MONITORING_NAMESPACE="monitoring"
INGRESS_NAMESPACE="ingress-nginx"

###############################################################################
# MongoDB
###############################################################################

line

if statefulset_exists "${APP_NAMESPACE}" "mongodb"
then

    info "Checking MongoDB..."

    wait_statefulset "${APP_NAMESPACE}" "mongodb"

    success "MongoDB Healthy."

else

    warning "MongoDB StatefulSet not found."

fi

###############################################################################
# Application
###############################################################################

line

if deployment_exists "${APP_NAMESPACE}" "qbshop"
then

    info "Checking Application..."

    wait_deployment "${APP_NAMESPACE}" "qbshop"

    success "Application Healthy."

else

    warning "Application Deployment not found."

fi

###############################################################################
# Ingress
###############################################################################

line

info "Checking NGINX Ingress..."

kubectl wait \
    --namespace "${INGRESS_NAMESPACE}" \
    --for=condition=Ready \
    pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=300s

success "NGINX Ingress Healthy."

###############################################################################
# Monitoring
###############################################################################

line

if namespace_exists "${MONITORING_NAMESPACE}"
then

    info "Checking Monitoring..."

    wait_namespace "${MONITORING_NAMESPACE}"

    success "Monitoring Healthy."

else

    warning "Monitoring namespace not found."

fi

###############################################################################
# ArgoCD
###############################################################################

line

if namespace_exists argocd
then

    info "Checking ArgoCD..."

    wait_namespace argocd

    success "ArgoCD Healthy."

else

    warning "ArgoCD namespace not found."

fi

###############################################################################
# Summary
###############################################################################

banner "Cluster Summary"

kubectl get nodes

echo

kubectl get pods -A

echo

kubectl get ingress -A || true

###############################################################################
# Finish
###############################################################################

echo
echo "============================================================"
echo "          Qualibytes Platform Ready"
echo "============================================================"
echo

echo "Application  : http://localhost"
echo "Grafana      : http://localhost:3000"
echo "Prometheus   : http://localhost:9090"
echo "ArgoCD       : kubectl port-forward svc/argocd-server -n argocd 8080:443"

echo
echo "============================================================"

completed "Health Check Completed."
