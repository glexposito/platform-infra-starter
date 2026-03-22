output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "resource_group_location" {
  value = module.resource_group.resource_group_location
}

output "resource_group_id" {
  value = module.resource_group.resource_group_id
}

output "storage_account_name" {
  value = module.storage_account.storage_account_name
}

output "storage_account_id" {
  value = module.storage_account.storage_account_id
}

output "storage_container_names" {
  value = module.storage_account.container_names
}

output "container_app_environment_id" {
  value = module.aca_environment.container_app_environment_id
}
