location         = "westeurope"
region_code      = "weu"
environment      = "prod"
stack_name       = "platform-nc"
app_name         = "myapp-1"
container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 0.25
container_memory = 0.5

tags = {
  environment = "prod"
  region      = "westeurope"
  app         = "myapp-1"
}
