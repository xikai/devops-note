resource "alicloud_slb_load_balancer" "clb" {
  load_balancer_name    = "${var.env}-${var.project_name}-${var.clb_name}-clb"
  payment_type          = var.payment_type
  load_balancer_spec    = var.load_balancer_spec
  vswitch_id            = var.vswitch_id
  address_type          = "intranet"
  resource_group_id     = var.resource_group_id
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.clb_name}-clb"
    Environment = var.env
    Project     = var.project_name
  }
}

resource "alicloud_eip_address" "clb_eip" {
  count                     = var.internat_enable ? 1 : 0
  address_name              = "${var.env}-${var.project_name}-${var.clb_name}-eip"
  netmode                   = "public"
  isp                       = "BGP"
  bandwidth                 = var.clb_eip_bandwidth
  internet_charge_type      = var.clb_internet_charge_type
  payment_type              = var.payment_type
  resource_group_id         = var.resource_group_id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_eip_association" "clb_eip_association" {
  count         = var.internat_enable ? 1 : 0
  allocation_id = element(concat(alicloud_eip_address.clb_eip.*.id, [""]), 0)
  instance_id   = element(concat(alicloud_slb_load_balancer.clb.*.id, [""]), 0)
}