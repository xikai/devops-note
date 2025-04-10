variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "clb_name" {
  
}

variable "resource_group_id" {
  default = ""
}

variable "vswitch_id" {
  
}

variable "load_balancer_spec" {
  
}

variable "payment_type" {
  default = "PayAsYouGo"
}

variable "internat_enable" {
  default = false
}

variable "clb_eip_bandwidth" {
  default = 200
}

variable "clb_internet_charge_type" {
  default = "PayByTraffic"
}