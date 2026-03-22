locals {
  resource_group_name            = "rg-${var.stack_name}-${var.environment}-${var.region_code}"
  storage_account_name           = "stplat${var.environment}${var.region_code}"
  container_app_environment_name = "cae-${var.stack_name}-${var.environment}-${var.region_code}"
  log_analytics_workspace_name   = "law-${var.stack_name}-${var.environment}-${var.region_code}"
  default_tags = {
    app         = var.stack_name
    environment = var.environment
    managed_by  = "terraform"
  }
  tags = merge(var.tags, local.default_tags)
}
