variable "env" {}

variable "project_name" {}

variable "app_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "instance_num" {
  type = number
}

variable "image_id" {
  type = string
}

variable "security_groups" {
  type = list
}

variable "ecs_subnet_public" {
  type = bool
}

variable "private_subnet_id" {
  
}

variable "public_subnet_id" {
  
}

variable "instance_charge_type" {
  type = string
  default = "PostPaid"
}

variable "internet_charge_type" {
  type = string
  default = "PayByTraffic"
}

variable "internet_max_bandwidth_out" {
  type = string
  default = 0
}

variable "eip_bandwidth" {
  type = string
  default = 5
}

variable "system_disk_category" {
  default = "cloud_efficiency"
}

variable "system_disk_size" {
  default = 40
}

variable "data_disk_size" {

}

variable "data_disk_device" {
  
}

variable "key_name" {
  description = "ssh key name"
}

variable "resource_group_id" {
  default = ""
}
