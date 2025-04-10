resource "alicloud_security_group" "security_group" {
  name        = "${var.env}-${var.project_name}-${var.sg_name}-sg"
  description = "${var.env}-${var.project_name}-${var.sg_name}-sg"
  vpc_id      = var.vpc_id
  security_group_type = "normal"
  inner_access_policy = "Accept"
  resource_group_id   = var.resource_group_id

  tags = {
    Project       = var.project_name
    Environment   = var.env
  }
}

resource "alicloud_security_group_rule" "inbound_rules" {
  for_each                   = var.inbound_rules
  security_group_id          = alicloud_security_group.security_group.id
  type                       = "ingress"
  nic_type                   = "intranet"
  policy                     = each.value[0]
  priority                   = each.value[1]
  ip_protocol                = each.value[2]
  port_range                 = each.value[3]
  cidr_ip                    = each.value[4] == "cidr" ? each.value[5] : null
  source_security_group_id   = each.value[4] == "sg" ? each.value[5] : null
  prefix_list_id             = each.value[4] == "pl" ? each.value[5] : null
  description                = each.value[6]
}

resource "alicloud_security_group_rule" "outbound_rules" {
  for_each                   = var.outbound_rules
  security_group_id          = alicloud_security_group.security_group.id
  type                       = "egress"
  nic_type                   = "intranet"
  policy                     = each.value[0]
  priority                   = each.value[1]
  ip_protocol                = each.value[2]
  port_range                 = each.value[3]
  cidr_ip                    = each.value[4] == "cidr" ? each.value[5] : null
  source_security_group_id   = each.value[4] == "sg" ? each.value[5] : null
  prefix_list_id             = each.value[4] == "pl" ? each.value[5] : null
  description                = each.value[6]
}