variable "env" {}

variable "project_name" {}

variable "resource_group_id" {
  default = ""
}

variable "vpc_id" {}

variable "load_balancer_edition" {
  default = "Basic"
}

variable "deletion_protection_enabled" {
  default = false
}

variable "address_type" {
  default = "Internet"
}

variable "zone_ids" {
  type = list
}

variable "vswitch_ids" {
  type = list
}

variable "certificate_id" {
    
}

variable "server_group_protocol" {
  description = "server group protocol"
  default = "HTTP"
}

variable "server_group_type" {
  description = "server group protocol"
  default = "Instance"
}

variable "scheduler" {
  description = "The scheduling algorithm"
  default = "Wrr"
}

variable "sticky_session_enabled" {
  default = false
}

variable "sticky_session_type" {
  default = "Server"
}

variable "health_check_enabled" {
  default = true
}

variable "health_check_connect_port" {
  default = "0"
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_codes" {
  default = ["http_2xx", "http_3xx"]
}

variable "health_check_method" {
  default = "HEAD"
}

variable "health_check_http_version" {
  default = "HTTP1.1"
}

variable "health_check_interval" {
  default = 2
}

variable "health_check_timeout" {
  default = 5
}

variable "healthy_threshold" {
  default = 3
}

variable "unhealthy_threshold" {
  default = 3
}

variable "server_port" {

}

variable "server_ids" {

}
