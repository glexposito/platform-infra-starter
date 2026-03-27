location                   = "westeurope"
region_code                = "weu"
environment                = "dev"
stack_name                 = "platform-nc"
app_name                   = "myapp-1"
container_name             = "worker"
acr_name                   = "acrglexpositodevweu01"
acr_resource_group_name    = "rg-shared-acr-dev-weu"
container_image_repository = "hello-world"
container_image_tag        = "latest"
container_cpu              = 0.25
container_memory           = 0.5
exposed_ports = [
  {
    port     = 80
    protocol = "TCP"
  }
]
environment_variables = {
  ASPNETCORE_ENVIRONMENT = "Development"
}
key_vault_name                = "kvshareddevweu01"
key_vault_resource_group_name = "rg-shared-kv-dev-weu"
key_vault_secret_environment_variables = {
  API_TOKEN = "api-token"
}

tags = {
  environment = "dev"
}
