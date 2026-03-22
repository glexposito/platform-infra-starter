output "container_app_id" {
  value = azurerm_container_app.this.id
}

output "container_app_identity_principal_id" {
  value = try(azurerm_container_app.this.identity[0].principal_id, null)
}
