#!/usr/bin/env bash

echo ""
echo "========================================="
echo " QBShop Local Environment"
echo "========================================="

echo "Application:"
echo "http://localhost"

echo ""

echo "Grafana:"
kubectl get svc -n monitorings

echo ""

echo "Prometheus:"
kubectl get svc -n monitorings

echo ""

echo "Ingress:"
kubectl get ingress -A

echo ""

echo "Pods:"
kubectl get pods -A