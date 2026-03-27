#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Create an Azure Key Vault in a new resource group.

Required environment variables:
  AZURE_SUBSCRIPTION_ID   Azure subscription ID

Optional environment variables:
  LOCATION                Azure region (default: westeurope)
  RESOURCE_GROUP_NAME     Resource group name (default: rg-kv-weu-dev)
  KEY_VAULT_NAME          Key Vault name (default: kv<timestamp suffix>)
  ENABLE_RBAC             Enable RBAC authorization (default: true)

Example:
  export AZURE_SUBSCRIPTION_ID="0521a568-1fab-426a-ba4f-573ef36bdc32"
  export RESOURCE_GROUP_NAME="rg-myapp-kv-dev-weu"
  export KEY_VAULT_NAME="kvmyappdevweu01"
  ./scripts/create-key-vault.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

: "${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID first}"

LOCATION="${LOCATION:-westeurope}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-kv-weu-dev}"
ENABLE_RBAC="${ENABLE_RBAC:-true}"

if [[ -n "${KEY_VAULT_NAME:-}" ]]; then
  KEY_VAULT_NAME="${KEY_VAULT_NAME}"
else
  SUFFIX="$(date +%s | tail -c 7)"
  KEY_VAULT_NAME="kv${SUFFIX}"
fi

echo "Using subscription: ${AZURE_SUBSCRIPTION_ID}"
echo "Location: ${LOCATION}"
echo "Resource group: ${RESOURCE_GROUP_NAME}"
echo "Key Vault: ${KEY_VAULT_NAME}"
echo "RBAC enabled: ${ENABLE_RBAC}"

az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

if ! az group show --name "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  az group create \
    --name "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --output none
fi

if ! az keyvault show --name "${KEY_VAULT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  az keyvault create \
    --name "${KEY_VAULT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --enable-rbac-authorization "${ENABLE_RBAC}" \
    --output none
fi

KEY_VAULT_ID="$(az keyvault show --name "${KEY_VAULT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query id -o tsv)"
KEY_VAULT_URI="$(az keyvault show --name "${KEY_VAULT_NAME}" --resource-group "${RESOURCE_GROUP_NAME}" --query properties.vaultUri -o tsv)"

echo
echo "Key Vault created or already present."
echo "  resource_group_name=${RESOURCE_GROUP_NAME}"
echo "  key_vault_name=${KEY_VAULT_NAME}"
echo "  key_vault_id=${KEY_VAULT_ID}"
echo "  key_vault_uri=${KEY_VAULT_URI}"
