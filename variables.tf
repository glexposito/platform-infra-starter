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
}

variable "container_image_tag" {
  type    = string
  default = "latest"
}

variable "acr_name" {
  type    = string
  default = null

  validation {
    condition     = (var.acr_name == null) == (var.acr_resource_group_name == null)
    error_message = "acr_name and acr_resource_group_name must be set together."
  }
}

variable "acr_resource_group_name" {
  type    = string
  default = null

  validation {
    condition     = (var.acr_resource_group_name == null) == (var.acr_name == null)
    error_message = "acr_resource_group_name and acr_name must be set together."
  }
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

  validation {
    condition     = (var.key_vault_name == null) == (var.key_vault_resource_group_name == null)
    error_message = "key_vault_name and key_vault_resource_group_name must be set together."
  }
}

variable "key_vault_resource_group_name" {
  type    = string
  default = null

  validation {
    condition     = (var.key_vault_resource_group_name == null) == (var.key_vault_name == null)
    error_message = "key_vault_resource_group_name and key_vault_name must be set together."
  }
}

variable "key_vault_secret_environment_variables" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
