#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

LOG_DIR="/tmp/qualibytes-portforward"

print_header "Starting Port Forward Services"

###########################################################
# Create Log Directory
###########################################################

mkdir -p "$LOG_DIR"

###########################################################
# Stop Old Port Forwards
###########################################################

info "Stopping old port forwards..."

pkill -f "kubectl port-forward" >/dev/null 2>&1 || true

sleep 2

success "Old port forwards stopped."

###########################################################
# Start ArgoCD
###########################################################

info "Starting ArgoCD..."

nohup kubectl port-forward \
svc/argocd-server \
-n argocd \
8080:443 \
--address=0.0.0.0 \
>"$LOG_DIR/argocd.log" 2>&1 &

###########################################################
# Start Grafana
###########################################################

info "Starting Grafana..."

nohup kubectl port-forward \
svc/prometheus-grafana \
-n monitoring \
3000:80 \
--address=0.0.0.0 \
>"$LOG_DIR/grafana.log" 2>&1 &

###########################################################
# Start Prometheus
###########################################################

info "Starting Prometheus..."

nohup kubectl port-forward \
svc/prometheus-kube-prometheus-prometheus \
-n monitoring \
9090:9090 \
--address=0.0.0.0 \
>"$LOG_DIR/prometheus.log" 2>&1 &

###########################################################
# Wait
###########################################################

sleep 5

###########################################################
# Verify Port Forwards
###########################################################

FAILED=0

check_pf() {
    local NAME="$1"
    local PATTERN="$2"

    if pgrep -f "$PATTERN" >/dev/null; then
        success "$NAME Port Forward Running"
    else
        error "$NAME Port Forward Failed"
        FAILED=1
    fi
}

check_pf "ArgoCD" "kubectl port-forward.*argocd-server"
check_pf "Grafana" "kubectl port-forward.*prometheus-grafana"
check_pf "Prometheus" "kubectl port-forward.*prometheus-kube-prometheus-prometheus"

###########################################################
# Jenkins
###########################################################

info "Checking Jenkins..."

if systemctl is-active --quiet jenkins; then
    success "Jenkins Running"
else
    warning "Jenkins Not Running"
fi

###########################################################
# Exit if Failed
###########################################################

if [ "$FAILED" -ne 0 ]; then
    echo
    error "One or more port-forwards failed."
    echo
    echo "Check logs:"
    echo "------------------------------------"
    ls -lh "$LOG_DIR"
    echo "------------------------------------"
    exit 1
fi

###########################################################
# URLs
###########################################################

PUBLIC_IP=$(curl -s ifconfig.me)

echo
echo "=============================================="
echo "     Port Forward Started Successfully"
echo "=============================================="
echo
echo "Jenkins"
echo "http://$PUBLIC_IP:8082"
echo
echo "ArgoCD"
echo "https://$PUBLIC_IP:8080"
echo
echo "Grafana"
echo "http://$PUBLIC_IP:3000"
echo
echo "Prometheus"
echo "http://$PUBLIC_IP:9090"
echo
echo "=============================================="

###########################################################
# Show Listening Ports
###########################################################

ss -tulnp | grep -E ':3000|:8080|:8082|:9090' || true
