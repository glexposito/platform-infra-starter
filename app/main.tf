data "terraform_remote_state" "shared" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.shared_state_resource_group_name
    storage_account_name = var.shared_state_storage_account_name
    container_name       = var.shared_state_container_name
    key                  = var.shared_state_key
  }
}

locals {
  container_app_name = "ca-${var.app_name}-${var.environment}-${var.region_code}"
  default_tags = {
    app         = var.app_name
    environment = var.environment
    managed_by  = "terraform"
  }
  tags = merge(var.tags, local.default_tags)
}
