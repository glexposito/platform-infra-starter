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
  resolved_container_image = var.acr_name == null ? var.container_image : format(
    "%s/%s:%s",
    data.azurerm_container_registry.this[0].login_server,
    var.container_image_repository,
    var.container_image_tag,
  )
}

resource "azurerm_user_assigned_identity" "acr_pull" {
  count = var.acr_name == null ? 0 : 1

  name                = local.acr_pull_identity_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  count = var.acr_name == null ? 0 : 1

  scope                = data.azurerm_container_registry.this[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull[0].principal_id
}

resource "time_sleep" "acr_rbac_propagation" {
  count = var.acr_name == null ? 0 : 1

  depends_on = [
    azurerm_role_assignment.acr_pull,
  ]

  create_duration = "45s"
}

data "azurerm_key_vault_secret" "env" {
  for_each = var.key_vault_name == null ? {} : var.key_vault_secret_environment_variables

  name         = each.value
  key_vault_id = data.azurerm_key_vault.this[0].id
}

data "azurerm_container_registry" "this" {
  count = var.acr_name == null ? 0 : 1

  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
}

data "azurerm_key_vault" "this" {
  count = var.key_vault_name == null ? 0 : 1

  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

check "acr_image_matches_registry" {
  assert {
    condition = var.acr_name == null || (
      var.container_image_repository != null &&
      length(trimspace(var.container_image_repository)) > 0
    )
    error_message = "container_image_repository must be set when acr_name is set."
  }
}

check "public_or_acr_image_input" {
  assert {
    condition = (
      var.acr_name == null && var.container_image != null
      ) || (
      var.acr_name != null && var.container_image == null
    )
    error_message = "Set container_image for public images, or set acr_name plus container_image_repository for ACR images."
  }
}

module "aci" {
  source = "./modules/aci"

  depends_on = [
    time_sleep.acr_rbac_propagation,
  ]

  name                         = local.container_group_name
  location                     = azurerm_resource_group.this.location
  resource_group_name          = azurerm_resource_group.this.name
  container_name               = var.container_name
  container_image              = local.resolved_container_image
  registry_server              = var.acr_name == null ? null : data.azurerm_container_registry.this[0].login_server
  acr_pull_identity_id         = var.acr_name == null ? null : azurerm_user_assigned_identity.acr_pull[0].id
  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  os_type                      = var.os_type
  ip_address_type              = var.ip_address_type
  dns_name_label               = var.dns_name_label
  restart_policy               = var.restart_policy
  exposed_ports                = var.exposed_ports
  environment_variables        = var.environment_variables
  secure_environment_variables = local.merged_secure_environment_variables
  key_vault_id                 = var.key_vault_name == null ? null : data.azurerm_key_vault.this[0].id
  tags                         = local.tags
}
