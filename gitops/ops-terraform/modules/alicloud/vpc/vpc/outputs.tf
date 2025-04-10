output "vpc_id" {
  value = alicloud_vpc.default.id
}

output "common_zones" {
  value = local.common_zones
}

output "vswitch_id" {
  value = alicloud_vswitch.vswitch[*].id
}

output "vswitch_cidr_blocks" {
  value = alicloud_vswitch.vswitch.*.cidr_block
}

# output "default_sg_id" {
#   value = alicloud_security_group.default.id
# }