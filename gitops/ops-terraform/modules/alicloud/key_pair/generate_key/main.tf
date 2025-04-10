resource "tls_private_key" "generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "alicloud_ecs_key_pair" "ssh_key" {
  key_pair_name   = "${var.project_name}-${var.env}"
  public_key      = tls_private_key.generated_private_key.public_key_openssh
  resource_group_id   = var.resource_group_id
  
  tags = {
     Project     = var.project_name
     Environment = var.env
  }
}

resource "local_file" "generated_private_key" {
  filename = var.private_key
  content  = tls_private_key.generated_private_key.private_key_pem
  file_permission = "0600"
}