locals {
  resource_group_name  = "rg-${var.stack_name}-${var.environment}-${var.region_code}"
  container_group_name = "aci-${var.app_name}-${var.environment}-${var.region_code}"
  default_tags = {
    app         = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
  tags = merge(var.tags, local.default_tags)
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
  dns_name_label               = var.ip_address_type == "Private" ? null : var.dns_name_label
  restart_policy               = var.restart_policy
  exposed_ports                = var.exposed_ports
  subnet_ids                   = var.ip_address_type == "Private" ? [data.azurerm_subnet.this[0].id] : []
  environment_variables        = var.environment_variables
  secure_environment_variables = local.merged_secure_environment_variables
  key_vault_id                 = var.key_vault_name == null ? null : data.azurerm_key_vault.this[0].id
  tags                         = local.tags
}
