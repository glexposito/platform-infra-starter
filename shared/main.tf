locals {
  resource_group_name            = "rg-${var.stack_name}-${var.environment}-${var.region_code}"
  storage_account_name           = "st${replace(var.stack_name, "-", "")}${var.environment}${var.region_code}"
  container_app_environment_name = "cae-${var.stack_name}-${var.environment}-${var.region_code}"
  log_analytics_workspace_name   = "law-${var.stack_name}-${var.environment}-${var.region_code}"
}

module "resource_group" {
  source = "../../modules/resource-group"

  location            = var.location
  environment         = var.environment
  name                = var.stack_name
  resource_group_name = local.resource_group_name
  tags                = var.tags
}

module "storage_account" {
  source = "../../modules/storage-account"

  location                 = var.location
  environment              = var.environment
  name                     = var.stack_name
  resource_group_name      = module.resource_group.resource_group_name
  storage_account_name     = local.storage_account_name
  containers               = var.storage_containers
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

module "aca_environment" {
  source = "../../modules/aca-environment"

  location                       = var.location
  environment                    = var.environment
  name                           = var.stack_name
  resource_group_name            = module.resource_group.resource_group_name
  container_app_environment_name = local.container_app_environment_name
  log_analytics_workspace_name   = local.log_analytics_workspace_name
  tags                           = var.tags
}
