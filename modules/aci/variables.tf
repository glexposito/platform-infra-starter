variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "container_image" {
  type = string
}

variable "container_cpu" {
  type = number
}

variable "container_memory" {
  type = number
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

variable "tags" {
  type    = map(string)
  default = {}
}
