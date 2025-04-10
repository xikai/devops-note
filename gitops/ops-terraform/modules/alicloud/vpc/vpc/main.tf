resource "alicloud_vpc" "default" {
  vpc_name          = "${var.env}-${var.project_name}-vpc"
  cidr_block        = var.vpc_cidr_block
  resource_group_id = var.resource_group_id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

data "alicloud_zones" "ecs_zones" {
  available_resource_creation = "Instance"
}

data "alicloud_db_zones" "rds_zones" {}

data "alicloud_alb_zones" "alb_zones" {}

data "alicloud_nlb_zones" "nlb_zones" {}

data "alicloud_enhanced_nat_available_zones" "ngw_zones" {}

locals {
  ecs_zones  = data.alicloud_zones.ecs_zones.zones[*].id
  rds_zones  = data.alicloud_db_zones.rds_zones.zones[*].id
  alb_zones  = data.alicloud_alb_zones.alb_zones.zones[*].zone_id
  nlb_zones  = data.alicloud_nlb_zones.nlb_zones.zones[*].zone_id
  ngw_zones  = data.alicloud_enhanced_nat_available_zones.ngw_zones.zones[*].zone_id
}

# 计算交集
locals {
  common_zones = [
    for zone in local.ecs_zones : zone 
      if contains(local.rds_zones, zone) &&
         contains(local.alb_zones, zone) &&
         contains(local.nlb_zones, zone) &&
         contains(local.ngw_zones, zone)
  ]
}

resource "alicloud_vswitch" "vswitch" {
  count        = length(var.vswitch_cidr_blocks)
  vswitch_name = "${var.env}-${var.project_name}-${local.common_zones[count.index]}-vswitch"
  cidr_block   = var.vswitch_cidr_blocks[count.index]
  zone_id      = local.common_zones[count.index]
  vpc_id       = alicloud_vpc.default.id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_nat_gateway" "internet-natgw" {
  nat_gateway_name = "${var.env}-${var.project_name}-internet-natgw"
  vpc_id           = alicloud_vpc.default.id
  vswitch_id       = alicloud_vswitch.vswitch[0].id
  nat_type         = "Enhanced"
  network_type     = "internet"
}

resource "alicloud_eip_address" "nat_gateway_eip" {
  address_name              = "${var.env}-${var.project_name}-internet-natgw-eip"
  netmode                   = "public"
  isp                       = "BGP"
  bandwidth                 = var.nat_eip_bandwidth
  internet_charge_type      = var.nat_internet_charge_type
  payment_type              = "PayAsYouGo"
  resource_group_id         = var.resource_group_id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_eip_association" "nat_gateway_eip_association" {
  allocation_id = alicloud_eip_address.nat_gateway_eip.id
  instance_id   = alicloud_nat_gateway.internet-natgw.id
}

resource "alicloud_snat_entry" "internet-natgw" {
  for_each = { for idx, id in alicloud_vswitch.vswitch : idx => id }
  snat_table_id     = alicloud_nat_gateway.internet-natgw.snat_table_ids
  source_vswitch_id = each.value.id
  snat_ip           = alicloud_eip_address.nat_gateway_eip.ip_address
}


# resource "alicloud_security_group" "default" {
#   name   = "default"
#   vpc_id = alicloud_vpc.default.id
# }

# resource "alicloud_security_group_rule" "allow_all_tcp" {
#   type              = "ingress"
#   ip_protocol       = "tcp"
#   nic_type          = "intranet"
#   policy            = "accept"
#   port_range        = "1/65535"
#   priority          = 1
#   security_group_id = alicloud_security_group.default.id
#   cidr_ip           = "0.0.0.0/0"
# }
