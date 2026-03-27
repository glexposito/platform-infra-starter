locals {
  acr_pull_identity_name = "id-aci-acr-${var.environment}-${var.region_code}"
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

data "azurerm_container_registry" "this" {
  count = var.acr_name == null ? 0 : 1

  name                = var.acr_name
  resource_group_name = var.acr_resource_group_name
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
