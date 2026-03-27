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
  type = string
}

variable "registry_server" {
  type    = string
  default = null
}

variable "acr_id" {
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

variable "key_vault_id" {
  type    = string
  default = null
}

variable "key_vault_secret_environment_variables" {
  type    = map(string)
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
