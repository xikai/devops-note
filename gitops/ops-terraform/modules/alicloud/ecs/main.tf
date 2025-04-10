resource "alicloud_instance" "ecs" {
  count                       = var.instance_num
  instance_name               = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  vswitch_id                  = var.vswitch_id[count.index % length(var.vswitch_id)]
  security_groups             = var.security_groups
  key_name                    = var.key_name
  instance_charge_type        = var.instance_charge_type
  period                      = var.period
  period_unit                 = var.period_unit
  renewal_status              = var.renewal_status
  auto_renew_period           = var.auto_renew_period
  force_delete                = true
  internet_charge_type        = var.internet_charge_type
  internet_max_bandwidth_out  = var.internet_max_bandwidth_out
  system_disk_category        = var.system_disk_category
  system_disk_size            = var.system_disk_size
  system_disk_name            = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-root"
  system_disk_auto_snapshot_policy_id = var.snapshot_policy_id
  resource_group_id           = var.resource_group_id


  data_disks {
    name        = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-data"
    size        = var.data_disk_size
    category    = var.system_disk_category
    auto_snapshot_policy_id = var.snapshot_policy_id
  }

  #user_data = var.user_data
  user_data = templatefile(var.user_data_templatefile_path, {
    git_token                   = var.user_data_git_token
    mount_data_dir              = var.user_data_mount_data_dir
    oss_region                  = var.user_data_oss_region
    acr_region                  = var.user_data_acr_region
    project                     = var.project_name
    env                         = var.env
    server_id                   = "${count.index + 1}"
    docker_services             = var.user_data_docker_services
    playbooks                   = var.user_data_playbooks
    service_file                = var.user_data_service_file
    nacos_address               = var.user_data_nacos_ip
  })

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
  count                     = var.eip_bandwidth > 0 ? var.instance_num : 0
  address_name              = "${var.env}-${var.project_name}-${var.app_name}-${count.index + 1}-eip"
  netmode                   = "public"
  isp                       = "BGP"
  bandwidth                 = var.eip_bandwidth
  internet_charge_type      = var.internet_charge_type
  payment_type              = var.eip_payment_type
  resource_group_id         = var.resource_group_id

  tags = {
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "alicloud_eip_association" "instance_eip_association" {
  count         = var.eip_bandwidth > 0 ? var.instance_num : 0
  allocation_id = alicloud_eip_address.instance_eip[count.index].id
  instance_id   = alicloud_instance.ecs[count.index].id
}