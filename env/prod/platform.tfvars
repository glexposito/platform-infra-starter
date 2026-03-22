location           = "westeurope"
region_code        = "weu"
environment        = "prod"
stack_name         = "platform-noncritical"
storage_containers = ["app", "tfstate"]

tags = {
  environment = "prod"
  region      = "westeurope"
}
