variable "env" {
  description = "Define the build environment"
}

variable "project_name" {}
variable "prefix_name" {
  
}

variable "prefix_list_entries" {
  description = "List of CIDR blocks to add to the managed prefix list"
  type        = map(list(string))
}

#另一种写法
# variable "prefix_list_entries" {
#   description = "List of CIDR blocks to add to the managed prefix list"
#   type        = list(object({
#     cidr        = string
#     description = string
#   }))
# }