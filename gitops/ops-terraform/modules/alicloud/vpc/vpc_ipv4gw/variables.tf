variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}

variable "vpc_cidr_block" {
  description = "The top-level CIDR block for the VPC."
  default     = "172.16.0.0/16"
}

variable "subnet_cidr_blocks_public" {
  description = "The CIDR blocks to create the workstations in."
  default     = ["172.16.0.0/20", "172.16.16.0/20","172.16.32.0/20"]
}

variable "subnet_cidr_blocks_private" {
  description = "The CIDR blocks to create the workstations in private."
  default     = ["172.16.48.0/20", "172.16.64.0/20","172.16.80.0/20"]
}

variable "nat_eip_bandwidth" {
  type = string
  default = 200
}

variable "nat_internet_charge_type" {
  type = string
  default = "PayByTraffic"
}

variable "resource_group_id" {
  default = ""
}