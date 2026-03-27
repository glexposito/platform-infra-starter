output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "resource_group_location" {
  value = azurerm_resource_group.this.location
}

output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "container_group_id" {
  value = module.aci.id
}

output "container_group_identity_principal_id" {
  value = module.aci.identity_principal_id
}

output "container_group_ip_address" {
  value = module.aci.ip_address
}

output "container_group_fqdn" {
  value = module.aci.fqdn
}
