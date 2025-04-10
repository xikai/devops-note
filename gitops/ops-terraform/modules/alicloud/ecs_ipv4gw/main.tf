resource "alicloud_instance" "ecs" {
  count                       = var.instance_num
  instance_name               = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  vswitch_id                  = var.ecs_subnet_public ? var.public_subnet_id[count.index % length(var.public_subnet_id)] : var.private_subnet_id[count.index % length(var.private_subnet_id)]
  security_groups             = var.security_groups
  key_name                    = var.key_name
  instance_charge_type        = var.instance_charge_type
  internet_charge_type        = var.internet_charge_type
  internet_max_bandwidth_out  = var.internet_max_bandwidth_out
  system_disk_category        = var.system_disk_category
  system_disk_size            = var.system_disk_size
  system_disk_name            = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-root"
  resource_group_id           = var.resource_group_id

  data_disks {
    name        = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-data"
    size        = var.data_disk_size
    category    = var.system_disk_category
    device      = var.data_disk_device
  }

  volume_tags = {
    Environment   = var.env
    Project       = var.project_name
  }

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_eip_address" "instance_eip" {
  count                     = var.ecs_subnet_public ? var.instance_num : 0
  address_name              = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-eip"
  netmode                   = "public"
  isp                       = "BGP"
  bandwidth                 = var.eip_bandwidth
  internet_charge_type      = var.internet_charge_type
  payment_type              = "PayAsYouGo"

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_eip_association" "instance_eip_association" {
  count         = var.ecs_subnet_public ? var.instance_num : 0
  allocation_id = alicloud_eip_address.instance_eip[count.index].id
  instance_id   = alicloud_instance.ecs[count.index].id
}