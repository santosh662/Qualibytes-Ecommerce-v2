#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Check Prerequisites
###############################################################################

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

banner "Checking System Prerequisites"

###############################################################################
# Required Commands
###############################################################################

COMMANDS=(
docker
kubectl
kind
helm
git
make
)

FAILED=0

for CMD in "${COMMANDS[@]}"
do

    if command_exists "$CMD"
    then
        success "$CMD Installed"
    else
        error "$CMD Not Installed"
        FAILED=1
    fi

done

###############################################################################
# Stop if Commands Missing
###############################################################################

if [[ $FAILED -eq 1 ]]
then

    echo
    error "Required tools are missing."

    echo
    echo "Run:"
    echo

    echo "    make bootstrap"

    echo

    exit 1

fi

###############################################################################
# Docker Permission Check
###############################################################################

line

info "Checking Docker..."

if docker_ready
then

    success "Docker is Ready."

else

    warning "Docker is installed."

    echo
    warning "Docker permission is not active in this terminal."
    echo
    echo "Please refresh your terminal"
    echo "or reconnect to the EC2 instance."
    echo
    echo "After reconnecting run:"
    echo
    echo "    make start"
    echo

    exit 1

fi

###############################################################################
# Kubernetes Check
###############################################################################

line

if cluster_ready
then

    success "Kubernetes cluster reachable."

else

    warning "No Kubernetes cluster detected."

    warning "Cluster will be created during make start."

fi

###############################################################################
# Summary
###############################################################################

line

completed "System verification completed."
