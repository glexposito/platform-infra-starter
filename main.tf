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
  secure_environment_variables = var.secure_environment_variables
  tags                         = local.tags
}
