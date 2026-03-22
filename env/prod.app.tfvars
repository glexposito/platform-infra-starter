shared_state_resource_group_name  = "rg-aca-terraform-state"
shared_state_storage_account_name = "acainfratfstate01"
shared_state_container_name       = "tfstate"
shared_state_key                  = "platform/prod/shared.tfstate"
region_code                       = "weu"
environment                       = "prod"
app_name                          = "myapp-1"
container_image                   = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
min_replicas                      = 1
max_replicas                      = 1

environment_variables = {
  APP_ENV = "prod"
}

tags = {
  environment = "prod"
  app         = "myapp-1"
}
