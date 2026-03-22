output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "resource_group_location" {
  value = azurerm_resource_group.this.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_container_names" {
  value = [for container in azurerm_storage_container.this : container.name]
}

output "container_app_environment_id" {
  value = azurerm_container_app_environment.this.id
}
