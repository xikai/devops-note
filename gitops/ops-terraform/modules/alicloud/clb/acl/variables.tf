variable "acl_name" {
  
}

variable "project_name" {
  
}

variable "env" {
  
}

variable "acl_list" {
  type = map(list(any))  
}

variable "resource_group_id" {
  default = ""
}