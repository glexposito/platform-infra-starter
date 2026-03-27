resource "azurerm_container_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  ip_address_type     = var.ip_address_type
  dns_name_label      = var.dns_name_label
  subnet_ids          = var.subnet_ids
  restart_policy      = var.restart_policy
  tags                = var.tags

  identity {
    type         = var.acr_pull_identity_id == null ? "SystemAssigned" : "SystemAssigned, UserAssigned"
    identity_ids = var.acr_pull_identity_id == null ? null : [var.acr_pull_identity_id]
  }

  dynamic "image_registry_credential" {
    for_each = var.registry_server == null ? [] : [var.registry_server]
    content {
      server                    = var.registry_server
      user_assigned_identity_id = var.acr_pull_identity_id
    }
  }

  container {
    name   = var.container_name
    image  = var.container_image
    cpu    = var.container_cpu
    memory = var.container_memory

    environment_variables        = var.environment_variables
    secure_environment_variables = var.secure_environment_variables

    dynamic "ports" {
      for_each = var.exposed_ports
      content {
        port     = ports.value.port
        protocol = ports.value.protocol
      }
    }
  }
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  count                = var.key_vault_id == null ? 0 : 1
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_group.this.identity[0].principal_id
}
