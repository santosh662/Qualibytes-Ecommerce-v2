#!/usr/bin/env bash

set -euo pipefail

git config user.name "Jenkins"

git config user.email "jenkins@qbshop.local"

git add kubernetes/

git commit -m "ci: update image ${BUILD_NUMBER}" || true

git push origin dev