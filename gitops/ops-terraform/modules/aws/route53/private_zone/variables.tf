variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "zone_suffix" {
  default = "local"
}

variable "vpc_id" {
  description = "vpc id"
}