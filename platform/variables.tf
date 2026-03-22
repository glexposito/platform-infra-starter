variable "location" {
  type = string
}

variable "region_code" {
  type = string
}

variable "environment" {
  type = string
}

variable "storage_containers" {
  type    = set(string)
  default = []
}

variable "stack_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
