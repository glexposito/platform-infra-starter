platform_state = {
  resource_group_name  = "rg-aca-terraform-state"
  storage_account_name = "acainfratfstate01"
  container_name       = "tfstate"
  key                  = "platform/dev/platform.tfstate"
}

region_code      = "weu"
environment      = "dev"
app_name         = "myapp-1"
container_image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
container_cpu    = 0.25
container_memory = "0.5Gi"
min_replicas     = 1
max_replicas     = 1

tags = {
  environment = "dev"
  app         = "myapp-1"
}
