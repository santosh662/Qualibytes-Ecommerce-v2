#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Build Docker Images
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/common.sh"

banner "Building Docker Images"

APP_IMAGE="qualibytes-shop-app:local"
MIGRATION_IMAGE="qualibytes-shop-migration:local"

cd "${PROJECT_ROOT}"

###############################################################################
# Application Image
###############################################################################

line

info "Building Application Image..."

retry 2 docker build \
    -t "${APP_IMAGE}" \
    -f Dockerfile .

success "Application Image Built."

###############################################################################
# Migration Image
###############################################################################

line

info "Building Migration Image..."

retry 2 docker build \
    -t "${MIGRATION_IMAGE}" \
    -f scripts/Dockerfile.migration .

success "Migration Image Built."

###############################################################################
# Verification
###############################################################################

line

info "Verifying Docker Images..."

docker image inspect "${APP_IMAGE}" >/dev/null

docker image inspect "${MIGRATION_IMAGE}" >/dev/null

success "Docker Images Verified."

###############################################################################
# Show Images
###############################################################################

line

docker images | grep "qualibytes-shop"

###############################################################################
# Finish
###############################################################################

completed "Docker Image Build Completed."
