shared_state_resource_group_name  = "rg-aca-terraform-state"
shared_state_storage_account_name = "acainfratfstate01"
shared_state_container_name       = "tfstate"
shared_state_key                  = "platform/dev/shared.tfstate"
region_code                       = "weu"
environment                       = "dev"
app_name                          = "myapp-1"
container_image                   = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
min_replicas                      = 1
max_replicas                      = 1

environment_variables = {
  APP_ENV = "dev"
}

tags = {
  environment = "dev"
  app         = "myapp-1"
}
