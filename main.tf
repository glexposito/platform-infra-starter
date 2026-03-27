locals {
  resource_group_name    = "rg-${var.stack_name}-${var.environment}-${var.region_code}"
  container_group_name   = "aci-${var.app_name}-${var.environment}-${var.region_code}"
  acr_pull_identity_name = "id-aci-acr-${var.environment}-${var.region_code}"
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

resource "azurerm_user_assigned_identity" "acr_pull" {
  count = var.acr_id == null ? 0 : 1

  name                = local.acr_pull_identity_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.acr_id == null ? 0 : 1

  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull[0].principal_id
}

data "azurerm_key_vault_secret" "env" {
  for_each = var.key_vault_id == null ? {} : var.key_vault_secret_environment_variables

  name         = each.value
  key_vault_id = var.key_vault_id
}

data "azurerm_container_registry" "this" {
  count = var.acr_id == null ? 0 : 1

  name                = element(reverse(split("/", var.acr_id)), 0)
  resource_group_name = element(reverse(split("/", var.acr_id)), 4)
}

module "aci" {
  source = "./modules/aci"

  name                         = local.container_group_name
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  container_name               = var.container_name
  container_image              = var.container_image
  registry_server              = var.acr_id == null ? var.registry_server : data.azurerm_container_registry.this[0].login_server
  acr_pull_identity_id         = var.acr_id == null ? null : azurerm_user_assigned_identity.acr_pull[0].id
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
