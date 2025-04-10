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
