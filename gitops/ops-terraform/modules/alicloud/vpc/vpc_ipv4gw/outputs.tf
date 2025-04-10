output "vpc_id" {
  value = alicloud_vpc.default.id
}

output "common_zones" {
  value = local.common_zones
}

output "public_subnet_id" {
  value = alicloud_vswitch.public_vswitch[*].id
}

output "private_subnet_id" {
  value = alicloud_vswitch.private_vswitch[*].id
}

output "subnet_cidr_blocks_public" {
  value = alicloud_vswitch.public_vswitch.*.cidr_block
}

output "subnet_cidr_blocks_private" {
  value = alicloud_vswitch.private_vswitch.*.cidr_block
}

output "security_group_id" {
  value = alicloud_security_group.default.id
}