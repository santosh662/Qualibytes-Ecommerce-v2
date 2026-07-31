#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Deploy Application on Kind
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Deploying Qualibytes Application"

MANIFEST_DIR="${PROJECT_ROOT}/kubernetes"
NAMESPACE="qbshop"

###############################################################################
# Verify Manifest Directory
###############################################################################

if [[ ! -d "${MANIFEST_DIR}" ]]
then
    error "Kubernetes manifest directory not found."
    exit 1
fi

###############################################################################
# Deploy
###############################################################################

line

info "Applying Kubernetes manifests..."

retry 3 kubectl apply -f "${MANIFEST_DIR}"

success "Kubernetes manifests applied."

###############################################################################
# Wait Namespace
###############################################################################

line

info "Waiting for namespace..."

COUNT=0

until namespace_exists "${NAMESPACE}"
do
    COUNT=$((COUNT+1))

    if [[ $COUNT -gt 30 ]]
    then
        error "Namespace ${NAMESPACE} not found."
        exit 1
    fi

    sleep 2
done

success "Namespace Ready."

###############################################################################
# Wait MongoDB
###############################################################################

line

if statefulset_exists "${NAMESPACE}" "mongodb"
then

    info "Waiting for MongoDB..."

    wait_statefulset "${NAMESPACE}" "mongodb"

    success "MongoDB Ready."

else

    warning "MongoDB StatefulSet not found."

fi

###############################################################################
# Wait Application
###############################################################################

line

if deployment_exists "${NAMESPACE}" "qbshop"
then

    info "Waiting for Application..."

    wait_deployment "${NAMESPACE}" "qbshop"

    success "Application Ready."

else

    warning "Application deployment not found."

fi

###############################################################################
# Show Resources
###############################################################################

line

info "Current Resources"

kubectl get all -n "${NAMESPACE}"

###############################################################################
# Finish
###############################################################################

completed "Application Deployment Completed."
