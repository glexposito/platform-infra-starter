variable "platform_state" {
  type = object({
    resource_group_name  = string
    storage_account_name = string
    container_name       = string
    key                  = string
  })
}

variable "region_code" {
  type = string
}

variable "environment" {
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

variable "container_cpu" {
  type    = number
  default = 0.25
}

variable "container_memory" {
  type    = string
  default = "0.5Gi"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 1
}

variable "revision_mode" {
  type    = string
  default = "Single"
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "secret_environment_variables" {
  type = map(object({
    secret_name         = string
    secret_value        = optional(string)
    key_vault_secret_id = optional(string)
  }))
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
