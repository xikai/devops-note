resource "aws_lb" "alb" {
  name               = "${var.env}-${var.project_name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.internal ? var.private_subnet_id : var.public_subnet_id

  enable_deletion_protection = var.enable_deletion_protection

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = {
    Name          = "${var.env}-${var.project_name}-alb"
    Project       = var.project_name
    Environment   = var.env
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type  = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      #message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type  = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      #message_body = "Fixed response content"
      status_code  = "503"
    }
  }
}

resource "aws_lb_target_group" "default" {
  name        = "${var.env}-${var.project_name}-alb-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "default" {
  count            = length(var.target_instance_id)

  target_group_arn = aws_lb_target_group.default.arn
  target_id        = var.target_instance_id[count.index]
  port             = var.target_group_port
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = aws_lb_listener.http.arn

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_listener_rule" "https_forward_backend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }

  condition {
    path_pattern {
      #values = ["/*"]
      values = var.listenr_path_pattern
    }
  }

  condition {
    host_header {
      #values = ["www.example.com"]
      values = var.listenr_host_header
    }
  }
}
