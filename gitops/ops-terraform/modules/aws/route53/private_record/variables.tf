variable "zone_id" {
  description = "zone id"
}

variable "record_num" {
  type = number
}

variable "records_name" {
  type = list(string)
}

variable "ec2_private_ip" {
  type = list(string)
}