#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Create an Azure Container Registry in a resource group.

Required environment variables:
  AZURE_SUBSCRIPTION_ID   Azure subscription ID

Optional environment variables:
  LOCATION                Azure region (default: westeurope)
  RESOURCE_GROUP_NAME     Resource group name (default: rg-shared-acr-dev-weu)
  ACR_NAME                ACR name, globally unique (default: acr<timestamp suffix>)
  ACR_SKU                 ACR SKU (default: Basic)
  CREATE_RESOURCE_GROUP   Create the resource group if missing (default: true)
  IMPORT_SOURCE_IMAGE     Source image to import (default: mcr.microsoft.com/azuredocs/containerapps-helloworld:latest)
  IMPORT_TARGET_IMAGE     Target image name in ACR (default: hello-world:latest)

Example:
  export AZURE_SUBSCRIPTION_ID="0521a568-1fab-426a-ba4f-573ef36bdc32"
  export RESOURCE_GROUP_NAME="rg-shared-acr-dev-weu"
  export ACR_NAME="acrshareddevweu01"
  ./scripts/create-acr.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

: "${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID first}"

LOCATION="${LOCATION:-westeurope}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-shared-acr-dev-weu}"
ACR_SKU="${ACR_SKU:-Basic}"
CREATE_RESOURCE_GROUP="${CREATE_RESOURCE_GROUP:-true}"
IMPORT_SOURCE_IMAGE="${IMPORT_SOURCE_IMAGE:-mcr.microsoft.com/azuredocs/containerapps-helloworld:latest}"
IMPORT_TARGET_IMAGE="${IMPORT_TARGET_IMAGE:-hello-world:latest}"

if [[ -n "${ACR_NAME:-}" ]]; then
  ACR_NAME="${ACR_NAME}"
else
  SUFFIX="$(date +%s | tail -c 7)"
  ACR_NAME="acr${SUFFIX}"
fi

echo "Using subscription: ${AZURE_SUBSCRIPTION_ID}"
echo "Location: ${LOCATION}"
echo "Resource group: ${RESOURCE_GROUP_NAME}"
echo "ACR name: ${ACR_NAME}"
echo "ACR SKU: ${ACR_SKU}"
echo "Import source image: ${IMPORT_SOURCE_IMAGE}"
echo "Import target image: ${IMPORT_TARGET_IMAGE}"

az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

if [[ "${CREATE_RESOURCE_GROUP}" == "true" ]]; then
  if ! az group show --name "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
    az group create \
      --name "${RESOURCE_GROUP_NAME}" \
      --location "${LOCATION}" \
      --output none
  fi
fi

if ! az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  az acr create \
    --name "${ACR_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --sku "${ACR_SKU}" \
    --admin-enabled false \
    --output none
fi

az acr import \
  --name "${ACR_NAME}" \
  --source "${IMPORT_SOURCE_IMAGE}" \
  --image "${IMPORT_TARGET_IMAGE}" \
  --force \
  --output none

ACR_ID="$(az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query id -o tsv)"
ACR_LOGIN_SERVER="$(az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query loginServer -o tsv)"

echo
echo "ACR created or already present."
echo "  resource_group_name=${RESOURCE_GROUP_NAME}"
echo "  acr_name=${ACR_NAME}"
echo "  acr_id=${ACR_ID}"
echo "  registry_server=${ACR_LOGIN_SERVER}"
echo "  container_image=${ACR_LOGIN_SERVER}/${IMPORT_TARGET_IMAGE}"
