resource "alicloud_ecs_prefix_list" "prefix_list" {
  prefix_list_name        = "${var.env}-${var.project_name}-${var.prefix_name}-prefix"
  address_family              = "IPv4"
  max_entries             = length(var.prefix_list_entries)

  dynamic "entry" {
    for_each     = var.prefix_list_entries
    content {
      cidr         = entry.value[0]
      description  = entry.value[1]
    }
  }
}