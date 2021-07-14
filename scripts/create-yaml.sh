#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

REPO_PATH="$1"
LABEL="$2"

mkdir -p "${REPO_PATH}"

cat > "${REPO_PATH}/${LABEL}-sa.yaml" <<EOL
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${LABEL}
EOL
