variable "project_name" {
  description = "Default namespace"
}

variable "env" {
  description = "Define the build environment"
  default = "test"
}

variable "vpc_id" {
  description = "vpc_id"
}

variable "sg_name" {
  
}

variable "ingress_rules" {
  description = "The list of ingress  rules for the security group"
  type        = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    self            = bool
    prefix_list_ids = list(string)
    description     = string
  }))
  default     = []
}

variable "egress_rules" {
  description = "The list of egress  rules for the security group"
  type        = list(object({
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    self            = bool
    prefix_list_ids = list(string)
    description     = string
  }))
  default     = []
}