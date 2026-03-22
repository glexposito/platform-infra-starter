shared_state_key = "platform/dev/shared.tfstate"
region_code      = "weu"
environment      = "dev"
app_name         = "myapp-1"
container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
min_replicas     = 1
max_replicas     = 1

environment_variables = {
  APP_ENV = "dev"
}

tags = {
  environment = "dev"
  app         = "myapp-1"
}
