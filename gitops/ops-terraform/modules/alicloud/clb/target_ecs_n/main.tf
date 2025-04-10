resource "alicloud_slb_server_group" "server_group" {
  load_balancer_id = var.load_balancer_id
  name             = var.server_group_name
}

resource "alicloud_slb_server_group_server_attachment" "server_attachment" {
  count            = var.server_num
  server_group_id  = alicloud_slb_server_group.server_group.id
  port             = var.group_port
  weight           = var.weight
  server_id        = var.server_id[count.index]
}

resource "alicloud_slb_listener" "listener" {
  load_balancer_id = var.load_balancer_id
  bandwidth        = -1 
  server_group_id  = alicloud_slb_server_group.server_group.id
  frontend_port    = var.listen_port
  protocol         = var.listen_protocol
  acl_status       = var.acl_status
  acl_type         = var.acl_type
  acl_id           = var.acl_id
  description      = "${var.listen_protocol}_${var.listen_port}"
}