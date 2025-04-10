variable "lb_name" {
  description = "ln name"
  type        = string
}

variable "env" {
  description = "env"
}

variable "internal" {
  description = "internal or network"
  type        = bool
  default     = true
}

variable "subnets" {
  description = "subnets"
}

variable "project_name" {
  description = "project_name"
}

variable "security_group" {
  description = "security group id"
  type        = list(string)
}