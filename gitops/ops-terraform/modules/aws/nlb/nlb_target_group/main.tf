resource "aws_lb_target_group" "target_group" {
  name = "${var.env}-${var.project_name}-${var.target_group_name}"
  port = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id = var.vpc_id
  health_check {
    port = var.target_group_health_port
    protocol = var.target_group_health_protocol
  }
  tags = {
    Name         = "${var.env}-${var.project_name}-${var.target_group_name}"
    Environment  = var.env
    Project      = var.project_name
  }
}

resource "aws_lb_target_group_attachment" "target_group_attachment" {
  target_group_arn = aws_lb_target_group.target_group.arn
  for_each = {
    for k,v in var.instance_id:
    k => v
  }
  target_id = each.value
  
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = var.aws_lb_id
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}