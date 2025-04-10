variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "zone_suffix" {
  default = "local"
}

variable "resource_group_id" {
  default = ""
}
