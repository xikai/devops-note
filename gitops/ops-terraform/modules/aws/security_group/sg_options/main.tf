resource "aws_security_group" "ec2_sg" {
  name        = "${var.env}-${var.project_name}-${var.sg_name}-sg"
  description = "${var.env}-${var.project_name}-${var.sg_name}-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name          = "${var.env}-${var.project_name}-${var.sg_name}-sg"
    Project       = var.project_name
    Environment   = var.env
  }
}

resource "aws_security_group_rule" "inbound_rules" {
  for_each                   = var.inbound_rules
  security_group_id          = aws_security_group.ec2_sg.id
  type                       = "ingress"
  protocol                   = each.value[0]
  from_port                  = each.value[1]
  to_port                    = each.value[2]
  cidr_blocks                = each.value[3] == "cidr" ? [each.value[4]] : null
  source_security_group_id   = each.value[3] == "sg" ? each.value[4] : null
  self                       = each.value[3] == "self" ? each.value[4] : null
  prefix_list_ids            = each.value[3] == "pl" ? [each.value[4]] : null
  description                = each.value[5]
}

resource "aws_security_group_rule" "outbound_rules" {
  for_each                   = var.outbound_rules
  security_group_id          = aws_security_group.ec2_sg.id
  type                       = "egress"
  protocol                   = each.value[0]
  from_port                  = each.value[1]
  to_port                    = each.value[2]
  cidr_blocks                = each.value[3] == "cidr" ? [each.value[4]] : null
  source_security_group_id   = each.value[3] == "sg" ? each.value[4] : null
  self                       = each.value[3] == "self" ? each.value[4] : null
  prefix_list_ids            = each.value[3] == "pl" ? [each.value[4]] : null
  description                = each.value[5]
}
