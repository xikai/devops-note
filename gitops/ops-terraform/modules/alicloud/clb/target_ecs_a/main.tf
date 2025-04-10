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

resource "alicloud_slb_listener" "listener_https" {
  load_balancer_id = var.load_balancer_id
  bandwidth        = -1 
  server_group_id  = alicloud_slb_server_group.server_group.id
  frontend_port    = var.listen_port
  protocol         = var.listen_protocol
  acl_status       = var.acl_status
  acl_type         = var.acl_type
  acl_id           = var.acl_id
  health_check     = var.health_check
  health_check_uri = var.health_check == "on" ? var.health_check_uri : null
  health_check_method   = var.health_check == "on" ? var.health_check_method : null
  health_check_domain   = var.health_check == "on" ? var.health_check_domain : null
  server_certificate_id = var.listen_protocol == "https" ? var.server_certificate_id : null
  description      = "${var.listen_protocol}_${var.listen_port}"
}

resource "alicloud_slb_listener" "listener_http" {
  load_balancer_id = var.load_balancer_id
  frontend_port    = 80
  protocol         = "http"
  listener_forward = "on"
  forward_port     = 443
  description      = "http_80"
  depends_on = [ alicloud_slb_listener.listener_https ]
}