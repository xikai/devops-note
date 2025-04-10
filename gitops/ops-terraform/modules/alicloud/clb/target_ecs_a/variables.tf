variable "load_balancer_id" {
  
}

variable "server_group_name" {
  
}

variable "server_id" {
  
}

variable "server_num" {
  
}

variable "group_port" {
  
}

variable "weight" {
  default = 100
}

variable "listen_port" {
  
}

variable "listen_protocol" {
  
}

variable "acl_status" {
  default = "off"
}

variable "acl_id" {
  default = null
}

variable "acl_type" {
  default = null
}

variable "health_check" {
  default = "on"
}

variable "health_check_domain" {
  default = ""
}

variable "health_check_method" {
  default = "get"
}

variable "health_check_uri" {
  default = "/"
}

variable "server_certificate_id" {
  
}