locals {
  resource_group_name  = "rg-${var.stack_name}-${var.environment}-${var.region_code}"
  container_group_name = "aci-${var.app_name}-${var.environment}-${var.region_code}"
  default_tags = {
    managed_by = "terraform"
  }
  tags = merge(var.tags, local.default_tags)
  key_vault_secure_environment_variables = {
    for env_var_name, secret in data.azurerm_key_vault_secret.env :
    env_var_name => secret.value
  }
  merged_secure_environment_variables = merge(
    var.secure_environment_variables,
    local.key_vault_secure_environment_variables,
  )
}

data "azurerm_key_vault_secret" "env" {
  for_each = var.key_vault_id == null ? {} : var.key_vault_secret_environment_variables

  name         = each.value
  key_vault_id = var.key_vault_id
}

module "aci" {
  source = "./modules/aci"

  name                         = local.container_group_name
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  container_name               = var.container_name
  container_image              = var.container_image
  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  os_type                      = var.os_type
  ip_address_type              = var.ip_address_type
  dns_name_label               = var.dns_name_label
  restart_policy               = var.restart_policy
  exposed_ports                = var.exposed_ports
  environment_variables        = var.environment_variables
  secure_environment_variables = local.merged_secure_environment_variables
  key_vault_id                 = var.key_vault_id
  tags                         = local.tags
}
