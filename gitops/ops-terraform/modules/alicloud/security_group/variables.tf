variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "vpc_id" {}

variable "sg_name" {}

variable "inbound_rules" {
  type = map(list(any))  
}
variable "outbound_rules" {
  type = map(list(any))
}

variable "resource_group_id" {
  default = ""
}
