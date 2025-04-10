resource "alicloud_ecs_key_pair" "ssh_key" {
  key_pair_name       = "${var.project_name}-${var.env}"
  public_key          = var.public_key
  resource_group_id   = var.resource_group_id

  tags = {
     Project     = var.project_name
     Environment = var.env
  }
}