#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Load Docker Images into Kind
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Loading Docker Images into Kind"

CLUSTER_NAME="qualibytes"

APP_IMAGE="qualibytes-shop-app:local"
MIGRATION_IMAGE="qualibytes-shop-migration:local"

###############################################################################
# Verify Cluster
###############################################################################

if ! kind_cluster_exists
then

    error "Kind cluster not found."

    echo
    echo "Run:"
    echo
    echo "    make start"
    echo

    exit 1

fi

###############################################################################
# Verify Images
###############################################################################

line

info "Checking Docker Images..."

if ! docker image inspect "${APP_IMAGE}" >/dev/null 2>&1
then
    error "${APP_IMAGE} not found."
    exit 1
fi

if ! docker image inspect "${MIGRATION_IMAGE}" >/dev/null 2>&1
then
    error "${MIGRATION_IMAGE} not found."
    exit 1
fi

success "Docker Images Found."

###############################################################################
# Load Application Image
###############################################################################

line

info "Loading Application Image..."

retry 2 kind load docker-image \
    "${APP_IMAGE}" \
    --name "${CLUSTER_NAME}"

success "Application Image Loaded."

###############################################################################
# Load Migration Image
###############################################################################

line

info "Loading Migration Image..."

retry 2 kind load docker-image \
    "${MIGRATION_IMAGE}" \
    --name "${CLUSTER_NAME}"

success "Migration Image Loaded."

###############################################################################
# Verification
###############################################################################

line

info "Verifying Cluster..."

kubectl get nodes

success "Images Successfully Loaded."

###############################################################################
# Finish
###############################################################################

completed "Kind Image Loading Completed."
