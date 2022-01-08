#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

REPO_PATH="$1"
LABEL="$2"
PULL_SECRETS="$3"

mkdir -p "${REPO_PATH}"

YQ=$(command -v yq4 || command -v "${BIN_DIR}/yq4")
JQ=$(command -v jq || command -v "${BIN_DIR}/jq")

SA_JSON=$(echo '{"apiVersion":"v1","kind":"ServiceAccount","metadata":{}}' | "${JQ}" -c --arg NAME "${LABEL}" '.metadata.name = $NAME')

if [[ -n "${PULL_SECRETS}" ]]; then
  SA_JSON=$(echo "${SA_JSON}" | "${JQ}" -c --argjson PULL_SECRETS "${PULL_SECRETS}" '.imagePullSecrets = $PULL_SECRETS')
fi

echo "${SA_JSON}" | "${YQ}" e -P '.' - > "${REPO_PATH}/${LABEL}-sa.yaml"
