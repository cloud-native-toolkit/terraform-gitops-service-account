#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

NAME="$1"
CONTENT_DIR="$2"
APPLICATION_PATH="$2"
APPLICATION_BRANCH="$3"
NAMESPACE="$4"

# Install jq if not available
JQ=$(command -v jq || command -v ./bin/jq)

if [[ -z "${JQ}" ]]; then
  echo "jq missing. Installing"
  mkdir -p ./bin && curl -Lo ./bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x ./bin/jq
  JQ="${PWD}/bin/jq"
fi

SEMAPHORE="${REPO//\//-}.semaphore"
SEMAPHORE_ID="${SCRIPT_DIR//\//-}"

while true; do
  echo "Checking for semaphore"
  if [[ ! -f "${SEMAPHORE}" ]]; then
    echo -n "${SEMAPHORE_ID}" > "${SEMAPHORE}"

    if [[ $(cat "${SEMAPHORE}") == "${SEMAPHORE_ID}" ]]; then
      echo "Got the semaphore. Setting up gitops repo"
      break
    fi
  fi

  SLEEP_TIME=$((1 + $RANDOM % 10))
  echo "  Waiting $SLEEP_TIME seconds for semaphore"
  sleep $SLEEP_TIME
done

function finish {
  rm "${SEMAPHORE}"
}

trap finish EXIT

PAYLOAD_REPO=$(echo "${GITOPS_CONFIG}" | ${JQ} -r '.payload.repo')

PAYLOAD_BASE_PATH=$(echo "${GITOPS_CONFIG}" | ${JQ} -r '.payload.path')
PAYLOAD_PATH="${PAYLOAD_BASE_PATH}/${APPLICATION_PATH}"

PAYLOAD_TOKEN=$(echo "${GIT_CREDENTIALS}" | ${JQ} --arg REPO "${PAYLOAD_REPO}" -r 'select(.repo == $REPO) | .token')

CONFIG_REPO=$(echo "${GITOPS_CONFIG}" | ${JQ} -r '.argocd\-config.repo')
CONFIG_PATH=$(echo "${GITOPS_CONFIG}" | ${JQ} -r '.argocd\-config.path')
CONFIG_PROJECT=$(echo "${GITOPS_CONFIG}" | ${JQ} -r '.argocd\-config.project')

CONFIG_TOKEN=$(echo "${GIT_CREDENTIALS}" | ${JQ} --arg REPO "${CONFIG_REPO}" -r 'select(.repo == $REPO) | .token')

echo "Setting up payload gitops"
TOKEN="${PAYLOAD_TOKEN}" "${SCRIPT_DIR}/setup-payload.sh" "${NAME}" "${PAYLOAD_REPO}" "${PAYLOAD_PATH}" "${NAMESPACE}" "${CONTENT_DIR}"

echo "Setting up argocd config"
TOKEN="${CONFIG_TOKEN}" "${SCRIPT_DIR}/setup-argocd.sh" "${NAME}" "${CONFIG_REPO}" "${CONFIG_PATH}" "${CONFIG_PROJECT}" "${PAYLOAD_REPO}" "${PAYLOAD_PATH}" "${NAMESPACE}" "${APPLICATION_BRANCH}"
