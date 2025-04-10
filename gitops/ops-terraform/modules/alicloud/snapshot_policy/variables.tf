variable "env" {}

variable "project_name" {}

variable "retention_days" {
  type = number
  default = 3
}

variable "repeat_weekdays" {
  type = list(string)
}

variable "time_points" {
  type = list(string)
}
