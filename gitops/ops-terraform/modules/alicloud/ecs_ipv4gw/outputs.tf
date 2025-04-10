output "instance_id" {
  value = alicloud_instance.ecs.*.id
}

output "instance_name" {
  value = alicloud_instance.ecs.*.instance_name
}

output "eip_id" {
  value = alicloud_eip_address.instance_eip.*.id
}