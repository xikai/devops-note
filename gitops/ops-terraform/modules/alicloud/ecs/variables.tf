variable "env" {}

variable "project_name" {}

variable "app_name" {
  type = string
}

variable "snapshot_policy_id" {
  default = null
}

variable "retention_days" {
  type = number
  default = 3
}

variable "repeat_weekdays" {
  type = list(string)
  default = ["1", "3", "5"]
}

variable "time_points" {
  type = list(string)
  default = ["3", "4", "5"]
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

variable "vswitch_id" {
  type = list
}

variable "instance_charge_type" {
  type = string
  default = "PostPaid"
}

variable "period" {
  type = string
  default = 1
}

variable "period_unit" {
  type = string
  default = "Month"
}

variable "renewal_status" {
  type = string
  default = "AutoRenewal"
}

variable "auto_renew_period" {
  type = string
  default = 1
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

variable "eip_payment_type" {
  type = string
  default = "PayAsYouGo"
}

variable "system_disk_category" {
  default = "cloud_efficiency"
}

variable "system_disk_size" {
  default = 40
}

variable "data_disk_size" {

}

variable "key_name" {
  description = "ssh key name"
}

variable "resource_group_id" {
  default = ""
}

#variable "user_data" {
#  description = "init script"
#  default = ""
#}

variable "user_data_templatefile_path" {
  default = ""
}

variable "user_data_git_token" {
  default = ""
}
  
variable "user_data_mount_data_dir" {
  default = ""
}

variable "user_data_oss_region" {
  default = ""
}

variable "user_data_acr_region" {
  default = ""
}

variable "user_data_docker_services" {
  type = list(string)
  default = []
}

variable "user_data_playbooks" {
  type = list(string)
  default = []
}

variable "user_data_service_file" {
  default = ""
}

variable "user_data_nacos_ip" {
  default = ""
}