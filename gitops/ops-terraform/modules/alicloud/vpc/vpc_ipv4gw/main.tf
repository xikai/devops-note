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

resource "alicloud_vswitch" "public_vswitch" {
  count        = length(var.subnet_cidr_blocks_public)
  vswitch_name = "${var.env}-${var.project_name}-${local.common_zones[count.index]}-public-vswitch"
  cidr_block   = var.subnet_cidr_blocks_public[count.index]
  zone_id      = local.common_zones[count.index]
  vpc_id       = alicloud_vpc.default.id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_vswitch" "private_vswitch" {
  count        = length(var.subnet_cidr_blocks_private)
  vswitch_name = "${var.env}-${var.project_name}-${local.common_zones[count.index]}-private-vswitch"
  cidr_block   = var.subnet_cidr_blocks_private[count.index]
  zone_id      = local.common_zones[count.index]
  vpc_id       = alicloud_vpc.default.id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_vpc_ipv4_gateway" "default" {
  ipv4_gateway_name        = "${var.env}-${var.project_name}-ipv4gw"
  vpc_id                   = alicloud_vpc.default.id
  enabled                  = true
}

resource "alicloud_nat_gateway" "internet-natgw" {
  nat_gateway_name = "${var.env}-${var.project_name}-internet-natgw"
  vpc_id           = alicloud_vpc.default.id
  vswitch_id       = alicloud_vswitch.public_vswitch[0].id
  nat_type         = "Enhanced"
  eip_bind_mode    = "NAT"   #EIP normal mode, compatible with IPv4 gateway
  network_type     = "internet"
}

resource "alicloud_eip_address" "nat_gateway_eip" {
  address_name              = "${var.env}-${var.project_name}-internet-natgw-eip"
  netmode                   = "public"
  isp                       = "BGP"
  bandwidth                 = var.nat_eip_bandwidth
  internet_charge_type      = var.nat_internet_charge_type
  payment_type              = "PayAsYouGo"

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
  for_each = { for idx, id in alicloud_vswitch.private_vswitch : idx => id }
  snat_table_id     = alicloud_nat_gateway.internet-natgw.snat_table_ids
  source_vswitch_id = each.value.id
  snat_ip           = alicloud_eip_address.nat_gateway_eip.ip_address
}

resource "alicloud_route_table" "public_vswitch_rt" {
  route_table_name = "${var.env}-${var.project_name}-public-vswitch-rt"
  description      = "route to ipv4 gateway"
  vpc_id           = alicloud_vpc.default.id
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "ipv4_route" {
  route_table_id        = alicloud_route_table.public_vswitch_rt.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Ipv4Gateway"
  nexthop_id            = alicloud_vpc_ipv4_gateway.default.id
}

resource "alicloud_route_table" "private_vswitch_rt" {
  route_table_name = "${var.env}-${var.project_name}-private-vswitch-rt"
  description      = "route to internet nat gateway"
  vpc_id           = alicloud_vpc.default.id
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "internet_natgw_route" {
  route_table_id        = alicloud_route_table.private_vswitch_rt.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.internet-natgw.id
}

resource "alicloud_route_table_attachment" "public_vswitch_rt" {
  count          = length(var.subnet_cidr_blocks_public)
  vswitch_id     = alicloud_vswitch.public_vswitch[count.index].id
  route_table_id = alicloud_route_table.public_vswitch_rt.id
}

resource "alicloud_route_table_attachment" "private_vswitch_rt" {
  count          = length(var.subnet_cidr_blocks_private)
  vswitch_id     = alicloud_vswitch.private_vswitch[count.index].id
  route_table_id = alicloud_route_table.private_vswitch_rt.id
}


resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = alicloud_vpc.default.id
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}
