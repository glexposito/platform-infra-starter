location           = "westeurope"
region_code        = "weu"
environment        = "dev"
stack_name         = "platform-noncritical"
storage_containers = ["app", "tfstate"]

tags = {
  environment = "dev"
  region      = "westeurope"
}
