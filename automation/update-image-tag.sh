#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${1:?Usage: update-image-tag.sh <image-tag>}"
MANIFEST="kubernetes/08-qbshop-deployment.yaml"
IMAGE="mrsinghdev/qbshop-app"

if [[ ! "$IMAGE_TAG" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]]; then
  echo "ERROR: Invalid image tag: $IMAGE_TAG" >&2
  exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
  echo "ERROR: Manifest not found: $MANIFEST" >&2
  exit 1
fi

# Require exactly one app image reference.
MATCH_COUNT=$(grep -Ec \
  '^[[:space:]]*image:[[:space:]]*(qualibytes-shop-app:local|mrsinghdev/qbshop-app:[^[:space:]]+)$' \
  "$MANIFEST" || true)

if [[ "$MATCH_COUNT" -ne 1 ]]; then
  echo "ERROR: Expected exactly one app image reference; found $MATCH_COUNT" >&2
  exit 1
fi

sed -i -E \
  "s#^([[:space:]]*image:[[:space:]]*)(qualibytes-shop-app:local|mrsinghdev/qbshop-app:[^[:space:]]+)#\\1${IMAGE}:${IMAGE_TAG}#" \
  "$MANIFEST"

if ! grep -Eq \
  "^[[:space:]]*image:[[:space:]]*${IMAGE}:${IMAGE_TAG}$" \
  "$MANIFEST"; then
  echo "ERROR: App image tag verification failed" >&2
  exit 1
fi

echo "App image updated and verified: ${IMAGE}:${IMAGE_TAG}"
echo "Migration manifest was intentionally left unchanged."
