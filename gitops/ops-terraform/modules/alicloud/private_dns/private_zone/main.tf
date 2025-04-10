resource "alicloud_pvtz_zone" "private" {
  zone_name          = "${var.project_name}-${var.env}.${var.zone_suffix}"
  resource_group_id  = var.resource_group_id
}
