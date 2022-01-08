#!/usr/bin/env bash

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

export KUBECONFIG=$(cat .kubeconfig)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

NAMESPACE="gitops-service-account"
SERVICE_ACCOUNT="test-sa"
NAME="${SERVICE_ACCOUNT}-sa"
SERVER_NAME="default"

if [[ ! -f "payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/${NAME}.yaml" ]]; then
  echo "Payload missing: payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/${NAME}.yaml"
  exit 1
fi

cat "payload/1-infrastructure/namespace/${NAMESPACE}/${NAME}/${NAME}.yaml"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"
  exit 1
fi

cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/base/${NAMESPACE}-${NAME}.yaml"

if [[ ! -f "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml" ]]; then
  echo "Argocd config missing: argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"
  exit 1
fi

cat "argocd/1-infrastructure/cluster/${SERVER_NAME}/kustomization.yaml"

cd ..
rm -rf .testrepo

PULL_SECRETS=$(kubectl get sa -n "${NAMESPACE}" "${NAME}" -o yaml | yq e -o json '.imagePullSecrets' -)

if [[ -z "${PULL_SECRETS}" ]]; then
  echo "No pull secrets"
  exit 1
fi

echo "Pull secrets: ${PULL_SECRETS}"
