variable "target_group_name" {
  description = "target group name"
}

variable "target_group_port" {
  description = "target group port"
  type        = number 
}

variable "env" {
  description = "env"
  default     = "test"
}

variable "target_group_protocol" {
  description = "protocol"
  default     = "tcp"
}

variable "target_group_health_port" {
  description = "target group health port"
  type        = number 
  default     = 80
}

variable "target_group_health_protocol" {
  description = "heath protocol"
  default     = 80
}

variable "instance_id" {
  description = "instance id"
  
}

variable "vpc_id" {
  description = "vpc id"
}

variable "project_name" {
  description = "project_name"
}

variable "listener_port" {
  description = "listener port"
  type        = number
  
}

variable "listener_protocol" {
  description = "listener protocol"
  default     = "tcp"
}

variable "aws_lb_id" {
  description = "aws lb id"
}