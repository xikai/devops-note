variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "vpc_id" {
  description = "vpc id"
}

variable "ssl_certificate_arn" {
  description = "ssl certificate arn"
}

variable "security_groups" {
  description = "security groups ids"
  type = list(string)
}

variable "internal" {
  description = "create internal alb"
  type = bool
  default = false
}

variable "private_subnet_id" {
  type = list(string)
}

variable "public_subnet_id" {
  type = list(string)
}

variable "enable_deletion_protection" {
  default = true
}

variable "target_group_port" {
  description = "target group port"
}

variable "target_group_protocol" {
  description = "target group protocol"
  default = "HTTP"
}

variable "target_instance_id" {
  description = "target instence id"
  type = list(string)
}

variable "target_type" {
  description = "target group type"
  default = "instance"
}

variable "listenr_path_pattern" {
  description = "listenr path_pattern"
  type = list(string)
  default = ["/*"]
}

variable "listenr_host_header" {
  description = "listenr host_header"
  type = list(string)
}
