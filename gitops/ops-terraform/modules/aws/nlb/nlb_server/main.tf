resource "aws_lb" "nlb_ec2" {
  name               = "${var.env}-${var.project_name}-${var.lb_name}-nlb"
  load_balancer_type = "network"
  internal           = var.internal
  subnets            = [ for subnet in var.subnets : subnet.id ]
  security_groups    = var.security_group
  enable_cross_zone_load_balancing = true
  tags = {
    Name ="${var.env}-${var.project_name}-${var.lb_name}-nlb"
    Environment = var.env
    Project     = var.project_name
  }
}