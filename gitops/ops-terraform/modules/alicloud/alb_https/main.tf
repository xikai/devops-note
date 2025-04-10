resource "alicloud_alb_load_balancer" "alb" {
  load_balancer_name          = "${var.env}-${var.project_name}-alb"
  vpc_id                      = var.vpc_id
  address_type                = var.address_type
  address_allocated_mode      = "Fixed"
  load_balancer_edition       = var.load_balancer_edition
  resource_group_id           = var.resource_group_id
  deletion_protection_enabled = var.deletion_protection_enabled
  modification_protection_config {
    status = "NonProtection"
  }

  load_balancer_billing_config {
    pay_type = "PayAsYouGo"
  }

  dynamic "zone_mappings" {
    for_each = {for idx, val in var.vswitch_ids : idx => val if idx < length(var.zone_ids)}
    content {
      vswitch_id = zone_mappings.value
      zone_id    = var.zone_ids[zone_mappings.key]
    }
  }

  tags = {
    Project       = var.project_name
    Environment   = var.env
  }
}


resource "alicloud_alb_server_group" "default" {
  server_group_name = "${var.env}-${var.project_name}-server-group"
  server_group_type =var.server_group_type
  protocol          = var.server_group_protocol
  scheduler         = var.scheduler
  vpc_id            = var.vpc_id
  resource_group_id = var.resource_group_id
  sticky_session_config {
    sticky_session_enabled = var.sticky_session_enabled
    #cookie                 = var.sticky_session_cookie
    sticky_session_type    = var.sticky_session_type
  }
  health_check_config {
    health_check_enabled      = var.health_check_enabled
    health_check_connect_port = var.health_check_connect_port
    health_check_codes        = var.health_check_codes
    health_check_http_version = var.health_check_http_version
    health_check_method       = var.health_check_method
    health_check_path         = var.health_check_path
    health_check_protocol     = var.server_group_protocol
    health_check_interval     = var.health_check_interval
    health_check_timeout      = var.health_check_timeout
    healthy_threshold         = var.healthy_threshold
    unhealthy_threshold       = var.unhealthy_threshold
  }

  dynamic servers {
    for_each     = var.server_ids
    content {
      port        = var.server_port
      server_id   = servers.value
      server_type = "Ecs"
    }
  }
}


resource "alicloud_alb_listener" "http" {
  load_balancer_id     = alicloud_alb_load_balancer.alb.id
  listener_protocol    = "HTTP"
  listener_port        = 80
  listener_description = "http_80"

  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.default.id
      }
    }
  }
}

resource "alicloud_alb_listener" "https" {
  load_balancer_id     = alicloud_alb_load_balancer.alb.id
  listener_protocol    = "HTTPS"
  listener_port        = 443
  certificates {
    certificate_id     = var.certificate_id
  }
  listener_description = "https_443"

  default_actions {
    type = "ForwardGroup"
    forward_group_config {
      server_group_tuples {
        server_group_id = alicloud_alb_server_group.default.id
      }
    }
  }
}

resource "alicloud_alb_rule" "redirect_http_to_https" {
  rule_name   = "redirect_http_to_https"
  listener_id = alicloud_alb_listener.http.id
  priority    = "1"
  rule_conditions {
    path_config {
      values = ["/*"]
    }
    type = "Path"
  }

  rule_actions {
    redirect_config {
      port      =  443
      protocol  = "HTTPS"
      http_code = 301
    }
    order = "1"
    type  = "Redirect"
  }
}


