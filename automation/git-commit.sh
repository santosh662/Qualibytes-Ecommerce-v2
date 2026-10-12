#!/usr/bin/env bash

set -euo pipefail

# Configure Git commit identity
git config user.name "Jenkins"
git config user.email "jenkins@qbshop.local"

# Stage only Kubernetes manifests
git add kubernetes/

# Commit the updated app image tag
git commit -m "ci: update image ${BUILD_NUMBER}" || true

# Require GitHub credentials injected by Jenkins
: "${GIT_USERNAME:?Missing GIT_USERNAME}"
: "${GIT_PASSWORD:?Missing GIT_PASSWORD}"

# Authenticate Git push without embedding the token in the remote URL
AUTH=$(printf '%s:%s' "$GIT_USERNAME" "$GIT_PASSWORD" | base64 -w0)

git -c http.extraheader="AUTHORIZATION: basic ${AUTH}" push origin HEAD:dev

unset AUTH

echo "GitOps manifest commit and push completed successfully."
