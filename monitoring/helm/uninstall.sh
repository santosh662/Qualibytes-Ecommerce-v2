#!/usr/bin/env bash

helm uninstall prometheus -n monitoring || true

helm uninstall loki -n monitoring || true

kubectl delete namespace monitoring --ignore-not-found