variable "env" {
  description = "Define the build environment"
}

variable "project_name" {

}

variable "resource_types" {
  default = "INSTANCE"  # VOLUME 
}

variable "copy_tags" {
  default = true
}

variable "times" {
  type = list(string)
  default = [ "03:00" ]
}

variable "interval_unit" {
  type = string
  default = "HOURS"
}

variable "state" {
  default = "ENABLED" # DISABLED
}

variable "interval" {
  type = number
  default = 24
}

variable "retain_rule" {
  type = number
  default = 3
}

variable "target_tags" {
  type = map(string)
  default = {
    Environment = "Prod" // 默认值
  }
}