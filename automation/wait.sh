#!/usr/bin/env bash

echo "Waiting for Pods..."

kubectl wait \
--for=condition=Ready \
pods \
--all \
--all-namespaces \
--timeout=300s

echo "All Pods Ready."