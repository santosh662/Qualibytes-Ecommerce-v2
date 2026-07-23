#!/usr/bin/env bash

echo "Nodes"

kubectl get nodes

echo ""

echo "Namespaces"

kubectl get ns

echo ""

echo "Pods"

kubectl get pods -A

echo ""

echo "Services"

kubectl get svc -A

echo ""

echo "Ingress"

kubectl get ingress -A