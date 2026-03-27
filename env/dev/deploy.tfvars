location         = "westeurope"
region_code      = "weu"
environment      = "dev"
stack_name       = "platform-nc"
app_name         = "myapp-1"
container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 0.25
container_memory = 0.5

tags = {
  environment = "dev"
  region      = "westeurope"
  app         = "myapp-1"
}
