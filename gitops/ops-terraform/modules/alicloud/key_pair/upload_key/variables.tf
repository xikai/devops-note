variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "public_key" {
  description = "Instance Public Key"
  type        = string
}

variable "resource_group_id" {
  default = ""
}