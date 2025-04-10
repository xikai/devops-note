resource "alicloud_slb_acl" "acl" {
  name       = "${var.env}-${var.project_name}-${var.acl_name}"
  ip_version = "ipv4"
  resource_group_id = var.resource_group_id
}

resource "alicloud_slb_acl_entry_attachment" "attachment" { 
  for_each   = var.acl_list
  acl_id     = alicloud_slb_acl.acl.id
  entry      = each.value[0]
  comment    = each.value[1]
}