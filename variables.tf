variable "location" {
  type = string
}

variable "region_code" {
  type = string
}

variable "environment" {
  type = string
}

variable "stack_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "container_name" {
  type    = string
  default = "app"
}

variable "container_image" {
  type    = string
  default = null
}

variable "container_image_repository" {
  type    = string
  default = null

  validation {
    condition     = var.acr_name != null || var.container_image_repository == null
    error_message = "container_image_repository can only be set when acr_name is set."
  }
}

variable "container_image_tag" {
  type    = string
  default = "latest"

  validation {
    condition     = var.acr_name != null || var.container_image_tag == "latest"
    error_message = "container_image_tag can only be customized when acr_name is set."
  }
}

variable "acr_name" {
  type    = string
  default = null
}

variable "acr_resource_group_name" {
  type    = string
  default = null
}

variable "container_cpu" {
  type    = number
  default = 0.25
}

variable "container_memory" {
  type    = number
  default = 0.5
}

variable "os_type" {
  type    = string
  default = "Linux"
}

variable "ip_address_type" {
  type    = string
  default = "Public"
}

variable "virtual_network_address_space" {
  type    = list(string)
  default = ["10.0.0.0/27"]
}

variable "aci_subnet_address_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/28"]
}

variable "dns_name_label" {
  type    = string
  default = null
}

variable "restart_policy" {
  type    = string
  default = "Always"
}

variable "exposed_ports" {
  type = list(object({
    port     = number
    protocol = optional(string, "TCP")
  }))
  default = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "secure_environment_variables" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "key_vault_name" {
  type    = string
  default = null
}

variable "key_vault_resource_group_name" {
  type    = string
  default = null
}

variable "key_vault_secret_environment_variables" {
  type    = map(string)
  default = {}

  validation {
    condition = (
      var.key_vault_name != null ||
      length(var.key_vault_secret_environment_variables) == 0
    )
    error_message = "key_vault_secret_environment_variables requires key_vault_name and key_vault_resource_group_name."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
