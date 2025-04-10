resource "aws_security_group" "security_group" {
  vpc_id = var.vpc_id
  name = "${var.env}-${var.project_name}-${var.sg_name}-sg"
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port 
      protocol        = ingress.value.protocol 
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      self            = ingress.value.self
      prefix_list_ids = ingress.value.prefix_list_ids
      description     = ingress.value.description
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port 
      protocol        = egress.value.protocol 
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      self            = egress.value.self
      prefix_list_ids = egress.value.prefix_list_ids
      description     = egress.value.description
    }
  }
  
  tags = {
    Name        = "${var.env}-${var.project_name}-sg"
    Environment = var.env
    Project     = var.project_name
  }
}