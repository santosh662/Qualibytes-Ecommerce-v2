#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Starting Port Forward Services"

###########################################################
# Stop Old Port Forwards
###########################################################

info "Stopping old port forwards..."

pkill -f "kubectl port-forward" >/dev/null 2>&1 || true

sleep 2

success "Old port forwards stopped."

###########################################################
# ArgoCD
###########################################################

info "Starting ArgoCD..."

nohup kubectl port-forward svc/argocd-server \
-n argocd \
8080:443 \
--address=0.0.0.0 \
>/tmp/qualibytes-portforward/argocd.log 2>&1 &

sleep 2

###########################################################
# Grafana
###########################################################

info "Starting Grafana..."

nohup kubectl port-forward svc/prometheus-grafana \
-n monitoring \
3000:80 \
--address=0.0.0.0 \
>/tmp/qualibytes-portforward/grafana.log 2>&1 &

sleep 2

###########################################################
# Prometheus
###########################################################

info "Starting Prometheus..."

nohup kubectl port-forward svc/prometheus-kube-prometheus-prometheus \
-n monitoring \
9090:9090 \
--address=0.0.0.0 \
>/tmp/qualibytes-portforward/prometheus.log 2>&1 &

sleep 2

###########################################################
# Jenkins
###########################################################

info "Checking Jenkins..."

if systemctl is-active --quiet jenkins
then
    success "Jenkins already running on port 8082."
else
    warning "Jenkins is not running."
fi

###########################################################
# Done
###########################################################

echo
echo "=============================================="
echo " All Services Available"
echo "=============================================="
echo
echo "Jenkins"
echo "http://$(curl -s ifconfig.me):8082"
echo
echo "ArgoCD"
echo "http://$(curl -s ifconfig.me):8080"
echo
echo "Grafana"
echo "http://$(curl -s ifconfig.me):3000"
echo
echo "Prometheus"
echo "http://$(curl -s ifconfig.me):9090"
echo
echo "=============================================="

