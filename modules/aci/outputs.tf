output "id" {
  value = azurerm_container_group.this.id
}

output "identity_principal_id" {
  value = try(azurerm_container_group.this.identity[0].principal_id, null)
}

output "ip_address" {
  value = azurerm_container_group.this.ip_address
}

output "fqdn" {
  value = azurerm_container_group.this.fqdn
}
