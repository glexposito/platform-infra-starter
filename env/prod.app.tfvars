shared_state_key = "platform/prod/shared.tfstate"
region_code      = "weu"
environment      = "prod"
app_name         = "myapp-1"
container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
min_replicas     = 2
max_replicas     = 2

environment_variables = {
  APP_ENV = "prod"
}

tags = {
  environment = "prod"
  app         = "myapp-1"
}
