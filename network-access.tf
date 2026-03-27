check "private_network_inputs" {
  assert {
    condition = var.ip_address_type != "Private" || (
      var.network_resource_group_name != null &&
      var.virtual_network_name != null &&
      var.subnet_name != null
    )
    error_message = "Private ACI requires network_resource_group_name, virtual_network_name, and subnet_name."
  }

  assert {
    condition = var.ip_address_type == "Private" || (
      var.network_resource_group_name == null &&
      var.virtual_network_name == null &&
      var.subnet_name == null
    )
    error_message = "network_resource_group_name, virtual_network_name, and subnet_name must be unset unless ip_address_type is Private."
  }
}

data "azurerm_subnet" "this" {
  count = var.ip_address_type == "Private" ? 1 : 0

  name                 = var.subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.network_resource_group_name
}
