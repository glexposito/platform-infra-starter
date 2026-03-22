resource "azurerm_container_app" "this" {
  name                         = local.container_app_name
  container_app_environment_id = data.terraform_remote_state.platform.outputs.container_app_environment_id
  resource_group_name          = data.terraform_remote_state.platform.outputs.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = local.tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "secret" {
    for_each = nonsensitive(var.secret_environment_variables)
    content {
      name                = secret.value.secret_name
      value               = try(secret.value.secret_value, null)
      key_vault_secret_id = try(secret.value.key_vault_secret_id, null)
      identity            = try(secret.value.key_vault_secret_id, null) == null ? null : "System"
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.container_cpu
      memory = var.container_memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = nonsensitive(var.secret_environment_variables)
        content {
          name        = env.key
          secret_name = env.value.secret_name
        }
      }
    }
  }
}
