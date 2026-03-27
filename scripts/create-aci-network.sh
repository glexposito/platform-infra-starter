#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Create a resource group, VNet, and delegated subnet for private Azure Container Instances.

Required environment variables:
  AZURE_SUBSCRIPTION_ID   Azure subscription ID

Optional environment variables:
  LOCATION                Azure region (default: westeurope)
  RESOURCE_GROUP_NAME     Resource group name (default: rg-shared-network-dev-weu)
  VNET_NAME               Virtual network name (default: vnet-shared-dev-weu)
  SUBNET_NAME             Subnet name (default: snet-aci-dev-weu)
  VNET_ADDRESS_SPACE      VNet CIDR (default: 10.0.0.0/27)
  SUBNET_PREFIX           Subnet CIDR (default: 10.0.0.0/28)

Example:
  export AZURE_SUBSCRIPTION_ID="0521a568-1fab-426a-ba4f-573ef36bdc32"
  export RESOURCE_GROUP_NAME="rg-shared-network-dev-weu"
  export VNET_NAME="vnet-shared-dev-weu"
  export SUBNET_NAME="snet-aci-dev-weu"
  ./scripts/create-aci-network.sh
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

: "${AZURE_SUBSCRIPTION_ID:?Set AZURE_SUBSCRIPTION_ID first}"

LOCATION="${LOCATION:-westeurope}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-shared-network-dev-weu}"
VNET_NAME="${VNET_NAME:-vnet-shared-dev-weu}"
SUBNET_NAME="${SUBNET_NAME:-snet-aci-dev-weu}"
VNET_ADDRESS_SPACE="${VNET_ADDRESS_SPACE:-10.0.0.0/27}"
SUBNET_PREFIX="${SUBNET_PREFIX:-10.0.0.0/28}"

echo "Using subscription: ${AZURE_SUBSCRIPTION_ID}"
echo "Location: ${LOCATION}"
echo "Resource group: ${RESOURCE_GROUP_NAME}"
echo "VNet: ${VNET_NAME}"
echo "Subnet: ${SUBNET_NAME}"
echo "VNet address space: ${VNET_ADDRESS_SPACE}"
echo "Subnet prefix: ${SUBNET_PREFIX}"

az account set --subscription "${AZURE_SUBSCRIPTION_ID}"

if ! az group show --name "${RESOURCE_GROUP_NAME}" >/dev/null 2>&1; then
  az group create \
    --name "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}" \
    --output none
fi

if ! az network vnet show --resource-group "${RESOURCE_GROUP_NAME}" --name "${VNET_NAME}" >/dev/null 2>&1; then
  az network vnet create \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --name "${VNET_NAME}" \
    --location "${LOCATION}" \
    --address-prefixes "${VNET_ADDRESS_SPACE}" \
    --output none
fi

if ! az network vnet subnet show --resource-group "${RESOURCE_GROUP_NAME}" --vnet-name "${VNET_NAME}" --name "${SUBNET_NAME}" >/dev/null 2>&1; then
  az network vnet subnet create \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --vnet-name "${VNET_NAME}" \
    --name "${SUBNET_NAME}" \
    --address-prefixes "${SUBNET_PREFIX}" \
    --delegations "Microsoft.ContainerInstance/containerGroups" \
    --output none
fi

SUBNET_ID="$(az network vnet subnet show --resource-group "${RESOURCE_GROUP_NAME}" --vnet-name "${VNET_NAME}" --name "${SUBNET_NAME}" --query id -o tsv)"

echo
echo "ACI network created or already present."
echo "  network_resource_group_name=${RESOURCE_GROUP_NAME}"
echo "  virtual_network_name=${VNET_NAME}"
echo "  subnet_name=${SUBNET_NAME}"
echo "  subnet_id=${SUBNET_ID}"
