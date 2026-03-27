location         = "westeurope"
region_code      = "weu"
environment      = "dev"
stack_name       = "platform-nc"
app_name         = "myapp-1"
container_image  = "acrglexpositodevweu01.azurecr.io/hello-world:latest"
acr_id           = "/subscriptions/0521a568-1fab-426a-ba4f-573ef36bdc32/resourceGroups/rg-shared-acr-dev-weu/providers/Microsoft.ContainerRegistry/registries/acrglexpositodevweu01"
container_cpu    = 0.25
container_memory = 0.5
exposed_ports = [
  {
    port     = 80
    protocol = "TCP"
  }
]
environment_variables = {
  ASPNETCORE_ENVIRONMENT = "Development"
}
key_vault_id = "/subscriptions/0521a568-1fab-426a-ba4f-573ef36bdc32/resourceGroups/rg-shared-kv-dev-weu/providers/Microsoft.KeyVault/vaults/kvshareddevweu01"
key_vault_secret_environment_variables = {
  API_TOKEN = "api-token"
}

tags = {
  environment = "dev"
}
