output "key_name" {
  value = aws_key_pair.ssh_key.key_name
}

output "public_key" {
  value = tls_private_key.generated_private_key.public_key_openssh
}