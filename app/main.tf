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
}

module "app" {
  source = "../../modules/aca-app"

  environment                  = var.environment
  name                         = var.app_name
  resource_group_name          = data.terraform_remote_state.shared.outputs.resource_group_name
  container_app_environment_id = data.terraform_remote_state.shared.outputs.container_app_environment_id
  container_app_name           = local.container_app_name
  container_name               = var.container_name
  container_image              = var.container_image
  container_cpu                = var.container_cpu
  container_memory             = var.container_memory
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  revision_mode                = var.revision_mode
  environment_variables        = var.environment_variables
  secret_environment_variables = var.secret_environment_variables
  registry_server              = var.registry_server
  acr_id                       = var.acr_id
  tags                         = var.tags
}
