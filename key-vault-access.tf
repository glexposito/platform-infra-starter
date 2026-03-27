locals {
  key_vault_secure_environment_variables = {
    for env_var_name, secret in data.azurerm_key_vault_secret.env :
    env_var_name => secret.value
  }
  merged_secure_environment_variables = merge(
    var.secure_environment_variables,
    local.key_vault_secure_environment_variables,
  )
}

check "key_vault_inputs" {
  assert {
    condition     = (var.key_vault_name == null) == (var.key_vault_resource_group_name == null)
    error_message = "key_vault_name and key_vault_resource_group_name must be set together."
  }
}

data "azurerm_key_vault" "this" {
  count = var.key_vault_name == null ? 0 : 1

  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group_name
}

data "azurerm_key_vault_secret" "env" {
  for_each = var.key_vault_name == null ? {} : var.key_vault_secret_environment_variables

  name         = each.value
  key_vault_id = data.azurerm_key_vault.this[0].id
}
