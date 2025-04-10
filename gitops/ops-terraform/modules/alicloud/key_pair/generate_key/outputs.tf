output "key_name" {
  value = alicloud_ecs_key_pair.ssh_key.id
}

output "public_key" {
  value = tls_private_key.generated_private_key.public_key_openssh
}