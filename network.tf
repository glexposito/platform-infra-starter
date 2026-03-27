locals {
  virtual_network_name = "vnet-${var.stack_name}-${var.environment}-${var.region_code}"
  aci_subnet_name      = "snet-aci-${var.environment}-${var.region_code}"
}

resource "azurerm_virtual_network" "this" {
  count = var.ip_address_type == "Private" ? 1 : 0

  name                = local.virtual_network_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = var.virtual_network_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "aci" {
  count = var.ip_address_type == "Private" ? 1 : 0

  name                 = local.aci_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = var.aci_subnet_address_prefixes

  delegation {
    name = "aci"

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}
