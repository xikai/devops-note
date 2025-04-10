variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "instance_name" {
  description = "instance type name"
}

variable "instance_ami" {
  description = "instance image id"
}

variable "key_name" {
  description = "ssh key name"
}

variable "instance_type" {
  description = "Ec2 Type"
}

variable "ebs_volume_type" {
  default = "gp3"
}

variable "ebs_volume_root_size" {
  default = 20
}

variable "vpc_security_group_ids" {
  description = "security_groups_id"
  type = list(string)
}

variable "instance_num" {
  type = number
}

variable "ec2_subnet_public" {
  type = bool
}

variable "private_subnet_id" {
  
}

variable "public_subnet_id" {
  
}

variable "additional_ebs_volumes" {
  description = "add additional_ebs_volumes"
  type = list(object({
    device_name   =  string
    volume_size   =  number
  }))
  default = [ ]
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