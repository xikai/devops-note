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

#variable "inbound_rules" {  
#  description = "The list of inbound rules for the security group"
#  type        = map(list(object({
#    from_port       = number
#    to_port         = number
#    protocol        = string
#    cidr_blocks     = list(string)
#    security_groups = list(string)
#    self            = bool
#    prefix_list_ids = list(string)
#    description     = string
#  })))
#  default     = {} 
#}
#
#variable "outbound_rules" {  
#  description = "The list of outbound rules for the security group"
#  type        = map(list(object({
#    from_port       = number
#    to_port         = number
#    protocol        = string
#    cidr_blocks     = list(string)
#    security_groups = list(string)
#    self            = bool
#    prefix_list_ids = list(string)
#    description     = string
#  })))
#  default     = {} 
#}