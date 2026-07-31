#!/usr/bin/env bash

###############################################################################
# Qualibytes Automation Framework v2
# Common Library
###############################################################################

set -Eeuo pipefail

###############################################################################
# Project Root
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

###############################################################################
# Colors
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

###############################################################################
# Error Trap
###############################################################################

trap 'echo; echo -e "${RED}[ERROR] Failed at line ${LINENO}.${NC}"; exit 1' ERR

###############################################################################
# Banner
###############################################################################

banner() {

echo
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}$1${NC}"
echo -e "${CYAN}============================================================${NC}"
echo

}

###############################################################################
# Horizontal Line
###############################################################################

line() {

echo "------------------------------------------------------------"

}

###############################################################################
# Logging
###############################################################################

info() {

echo -e "${BLUE}[INFO]${NC} $1"

}

success() {

echo -e "${GREEN}[SUCCESS]${NC} $1"

}

warning() {

echo -e "${YELLOW}[WARNING]${NC} $1"

}

error() {

echo -e "${RED}[ERROR]${NC} $1"

}

###############################################################################
# Finish Message
###############################################################################

completed() {

echo
success "$1"
echo

}

###############################################################################
# Command Exists
###############################################################################

command_exists() {

command -v "$1" >/dev/null 2>&1

}

###############################################################################
# Require File
###############################################################################

require_file() {

if [[ ! -f "$1" ]]
then

error "Required file not found."

echo

echo "$1"

echo

exit 1

fi

}

###############################################################################
# Require Directory
###############################################################################

require_directory() {

if [[ ! -d "$1" ]]
then

error "Required directory not found."

echo

echo "$1"

echo

exit 1

fi

}
###############################################################################
# Retry Function
###############################################################################

retry() {

    local retries="$1"
    shift

    local count=1

    until "$@"
    do

        if [[ $count -ge $retries ]]
        then
            error "Maximum retry attempts reached."
            return 1
        fi

        warning "Attempt ${count}/${retries} failed. Retrying in 5 seconds..."

        sleep 5

        count=$((count + 1))

    done

}

###############################################################################
# Docker Ready
###############################################################################

docker_ready() {

    docker info >/dev/null 2>&1

}

###############################################################################
# Kubernetes Ready
###############################################################################

cluster_ready() {

    kubectl cluster-info >/dev/null 2>&1

}

###############################################################################
# Kind Cluster Exists
###############################################################################

kind_cluster_exists() {

    kind get clusters 2>/dev/null | grep -Fxq "qualibytes"

}

###############################################################################
# Namespace Exists
###############################################################################

namespace_exists() {

    kubectl get namespace "$1" >/dev/null 2>&1

}

###############################################################################
# Deployment Exists
###############################################################################

deployment_exists() {

    local namespace="$1"
    local deployment="$2"

    kubectl get deployment \
        "${deployment}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

###############################################################################
# StatefulSet Exists
###############################################################################

statefulset_exists() {

    local namespace="$1"
    local statefulset="$2"

    kubectl get statefulset \
        "${statefulset}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

###############################################################################
# Service Exists
###############################################################################

service_exists() {

    local namespace="$1"
    local service="$2"

    kubectl get service \
        "${service}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}

###############################################################################
# ConfigMap Exists
###############################################################################

configmap_exists() {

    local namespace="$1"
    local configmap="$2"

    kubectl get configmap \
        "${configmap}" \
        -n "${namespace}" \
        >/dev/null 2>&1

}
###############################################################################
# Wait For Deployment
###############################################################################

wait_deployment() {

    local namespace="$1"
    local deployment="$2"

    info "Waiting for deployment ${deployment}..."

    if kubectl rollout status \
        deployment/"${deployment}" \
        -n "${namespace}" \
        --timeout=600s
    then

        success "Deployment ${deployment} Ready."

    else

        warning "Rollout timeout reached."

        info "Checking deployment status..."

        AVAILABLE=$(kubectl get deployment "${deployment}" \
            -n "${namespace}" \
            -o jsonpath='{.status.availableReplicas}')

        DESIRED=$(kubectl get deployment "${deployment}" \
            -n "${namespace}" \
            -o jsonpath='{.status.replicas}')

        if [[ "$AVAILABLE" == "$DESIRED" && "$AVAILABLE" != "" ]]
        then
            success "Deployment is already available."
            return 0
        fi

        error "Deployment failed."
        exit 1

    fi

}

###############################################################################
# Wait For StatefulSet
###############################################################################

wait_statefulset() {

    local namespace="$1"
    local statefulset="$2"

    kubectl rollout status \
        statefulset/"${statefulset}" \
        -n "${namespace}" \
        --timeout=300s

}

###############################################################################
# Wait For All Pods
###############################################################################

wait_pods() {
    local namespace="$1"
    kubectl wait \
        --for=condition=Ready \
        pod \
        --all \
        -n "${namespace}" \
        --timeout=300s
}

wait_namespace() {
    local namespace="$1"
    kubectl wait \
        --for=condition=Ready \
        pod \
        --all \
        -n "${namespace}" \
        --timeout=300s
}

###############################################################################
# Wait For Job
###############################################################################

wait_job() {

    local namespace="$1"
    local job="$2"

    kubectl wait \
        --for=condition=complete \
        job/"${job}" \
        -n "${namespace}" \
        --timeout=300s

}

###############################################################################
# Wait For Ingress Controller
###############################################################################

wait_ingress() {

    kubectl wait \
        --namespace ingress-nginx \
        --for=condition=Ready \
        pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s

}

###############################################################################
# Show Cluster Nodes
###############################################################################

show_nodes() {

    line
    info "Cluster Nodes"

    kubectl get nodes -o wide

}

###############################################################################
# Show Pods
###############################################################################

show_pods() {

    line
    info "Pods"

    kubectl get pods -A

}

###############################################################################
# Show Services
###############################################################################

show_services() {

    line
    info "Services"

    kubectl get svc -A

}

###############################################################################
# Show Ingress
###############################################################################

show_ingress() {

    line
    info "Ingress"

    kubectl get ingress -A || true

}

###############################################################################
# Show Namespaces
###############################################################################

show_namespaces() {

    line
    info "Namespaces"

    kubectl get ns

}
###############################################################################
# Verify Docker
###############################################################################

verify_docker() {

    info "Checking Docker..."

    if docker_ready
    then
        success "Docker is running."
    else
        error "Docker service is not running."
        exit 1
    fi

}

###############################################################################
# Verify Kubernetes Cluster
###############################################################################

verify_cluster() {

    info "Checking Kubernetes Cluster..."

    if cluster_ready
    then
        success "Kubernetes cluster is reachable."
    else
        error "Kubernetes cluster is not reachable."
        exit 1
    fi

}

###############################################################################
# Verify Namespace
###############################################################################

verify_namespace() {

    local namespace="$1"

    if namespace_exists "${namespace}"
    then
        success "Namespace '${namespace}' exists."
    else
        error "Namespace '${namespace}' not found."
        exit 1
    fi

}

###############################################################################
# Platform URLs
###############################################################################

print_platform_urls() {

    echo
    line

    echo "Application : http://localhost"
    echo "Grafana    : http://localhost:3000"
    echo "Prometheus : http://localhost:9090"
    echo "ArgoCD     : kubectl port-forward svc/argocd-server -n argocd 8080:443"

    line
    echo

}

###############################################################################
# Cleanup
###############################################################################

cleanup_on_exit() {

    local code=$?

    if [[ ${code} -ne 0 ]]
    then
        echo
        error "Automation failed."
    fi

}

trap cleanup_on_exit EXIT

print_header() {
    echo "======================================"
    echo "$1"
    echo "======================================"
}

###############################################################################
# End of File
###############################################################################
