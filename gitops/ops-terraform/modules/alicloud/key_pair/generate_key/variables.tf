variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "private_key" {
  description = "Instance Private Key"
  type        = string
}

variable "resource_group_id" {
  default = ""
}