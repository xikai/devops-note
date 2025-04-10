terraform {
  # backend "oss" {
  #   bucket              = "vevor-terraform-state"
  #   prefix              = "projects/ali-xikai-test"
  #   key                 = "terraform.tfstate"
  #   region              = "cn-shenzhen"
  #   tablestore_endpoint = "https://vevor-terraform.cn-shenzhen.ots.aliyuncs.com"
  #   tablestore_table    = "statelock"
  # }
    backend "s3" {
    dynamodb_table = "vevor-terraform-state-lock"
    bucket         = "vevor-terraform-remote-state"
    key            = "projects/poc-prod/terraform.tfstate"
    region         = "cn-north-1"
    encrypt        = true
  }
}

provider "alicloud" {
  region = "cn-beijing"
}

module "resource" {
  source              = "../../modules/alicloud/resource_manager/resource_group"
  resource_group_name = "alicloud-demo-test"
}

#module "vpc" {
#  source                        = "../../modules/alicloud/vpc/vpc_ipv4gw"
#
#  env                           = local.env
#  project_name                  = local.project_name
#  vpc_cidr_block                = "172.18.0.0/16"
#  subnet_cidr_blocks_public     = ["172.18.0.0/20", "172.18.16.0/20","172.18.32.0/20"]
#  subnet_cidr_blocks_private    = ["172.18.48.0/20", "172.18.64.0/20","172.18.80.0/20"]
#  nat_eip_bandwidth             = 200
#  nat_internet_charge_type      = "PayByTraffic"
#  resource_group_id             = module.resource.resource_group_id
#}

module "vpc" {
  source = "../../modules/alicloud/vpc/vpc"

  env                      = local.env
  project_name             = local.project_name
  vpc_cidr_block           = "172.18.0.0/16"
  vswitch_cidr_blocks      = ["172.18.0.0/20", "172.18.16.0/20", "172.18.32.0/20"]
  nat_eip_bandwidth        = 200
  nat_internet_charge_type = "PayByTraffic"
  resource_group_id        = module.resource.resource_group_id
}

module "prefix_list" {
  source = "../../modules/alicloud/prefix_list/ecs_pl"

  env          = local.env
  project_name = local.project_name
  prefix_name  = "demo1"
  prefix_list_entries = {
    "0" = ["192.168.0.1/32", "test01"]
    "1" = ["192.168.0.2/32", "test02"]
    "2" = ["192.168.0.3/32", "test03"]
  }
}

module "key_pair" {
  source = "../../modules/alicloud/key_pair/generate_key"

  env          = local.env
  project_name = local.project_name
  #public_key                    = file("~/.ssh/id_rsa.pub")
  private_key       = pathexpand("~/.ssh/${local.project_name}-${local.env}-private.pem")
  resource_group_id = module.resource.resource_group_id
}

module "ecs_sg" {
  source            = "../../modules/alicloud/security_group"
  vpc_id            = module.vpc.vpc_id
  sg_name           = "app"
  project_name      = local.project_name
  env               = local.env
  resource_group_id = module.resource.resource_group_id

  inbound_rules = {
    "0" = ["accept", 1, "tcp", "22/22", "cidr", "0.0.0.0/0", "allow 22"]
    "1" = ["accept", 1, "tcp", "22/22", "pl", module.prefix_list.prefix_list_id, "allow 22"]
  }
  outbound_rules = {
    "0" = ["accept", 1, "all", "-1/-1", "cidr", "0.0.0.0/0", "allow all"]
  }
}

data "alicloud_images" "centos_7_9" {
  owners       = "system"
  name_regex   = "^centos_7_9"
  architecture = "x86_64"
  most_recent  = true
}

data "alicloud_images" "aliyun_3" {
  owners       = "system"
  name_regex   = "^aliyun_3_*_uefi"
  architecture = "x86_64"
  most_recent  = true
}

# module "auto_snapsot_policy" {
#   source          = "../../modules/alicloud/snapshot_policy"
#   repeat_weekdays = ["1", "3", "5"]
#   time_points     = ["3", "4", "5"]
#   retention_days  = 3
#   env             = local.env
#   project_name    = local.project_name
# }

module "ecs" {
  source       = "../../modules/alicloud/ecs"
  instance_num = 1

  env                  = local.env
  project_name         = local.project_name
  app_name             = "app"
  image_id             = data.alicloud_images.centos_7_9.images.0.id
  instance_charge_type = "PostPaid"
  #instance_charge_type          = "PrePaid"       #PostPaid后付费(按量付费)，PrePaid预付费(包年包月)
  #period                        = 1               #PrePaid包年包月的购买时长
  #period_unit                   = "Month"         #PrePaid包年包月购买/续费时长的单位:月
  #renewal_status                = "AutoRenewal"   #PrePaid包年包月的续费方式
  #auto_renew_period             = 1               #PrePaid包年包月的续费时长
  instance_type              = "ecs.t5-c1m2.xlarge"
  system_disk_category       = "cloud_efficiency"
  system_disk_size           = 40
  data_disk_size             = 50
  internet_charge_type       = "PayByTraffic" #PayByTraffic按流量付费，PayByBandwidth按带宽付费
  internet_max_bandwidth_out = 0              #设置公网IP带宽峰值(0-200)设置为0时，不为实例分配公网IP
  eip_bandwidth              = 200            #设置EIP带宽峰值(0-200)，大于0时为实例分配EIP
  eip_payment_type           = "PayAsYouGo"   #PayAsYouGo按量付费，Subscription包年包月
  vswitch_id                 = module.vpc.vswitch_id
  security_groups            = [module.vpc.default_sg_id, module.ecs_sg.sg_id]
  key_name                   = module.key_pair.key_name
  resource_group_id          = module.resource.resource_group_id
  # snapshot_policy_id         = module.auto_snapsot_policy.snapshot_policy_id



  # user_data = templatefile("../../modules/alicloud/ecs/middleware_docker.tftpl", {
  user_data = templatefile("../../modules/alicloud/ecs/middleware_ansible.tftpl", {
    git_token      = "agp_cfdxxxxxxxxxxxxxxxxxxxxx"
    # start_services = ["mysql", "redis", "elasticsearch", "rabbitmq-3.7.28", "kafka", "zookeeper","apollo","mongo","nacos","nginx","rocketmq","canal"]
    playbooks = ["playbooks/sysctl.yml", "playbooks/openjdk-8u231.yml", "playbooks/nodejs-14.yml", "playbooks/zookeeper.yml"]
    # acr_region     = "cn-shanghai"
    oss_region     = "vevor-packages.oss-cn-shanghai"
    mount_data_dir = "/data"
  })
}


# module "alb_https" {
#   source                        = "../../modules/alicloud/alb_https"
#   env                           = local.env
#   project_name                  = local.project_name
#   vpc_id                        = module.vpc.vpc_id
#   resource_group_id             = module.resource.resource_group_id

#   address_type                  = "Internet"
#   load_balancer_edition         = "Basic"
#   deletion_protection_enabled   = false
#   zone_ids                      = module.vpc.common_zones
#   vswitch_ids                   = module.vpc.vswitch_id
#   certificate_id                = "13055473-cn-hangzhou"

#   server_group_type             = "Instance"
#   server_group_protocol         = "HTTP"
#   scheduler                     = "Wrr"
#   sticky_session_enabled        = false
#   health_check_enabled          = true
#   health_check_connect_port     = 0  //0表示使用server_port后端服务器端口检测
#   health_check_codes            = ["http_2xx", "http_3xx"]
#   health_check_http_version     = "HTTP1.1"
#   health_check_method           = "HEAD"
#   health_check_path             = "/"
#   health_check_interval         = 2
#   health_check_timeout          = 5
#   healthy_threshold             = 3
#   unhealthy_threshold           = 3

#   server_port                   = "8080"
#   server_ids                    = module.ecs.instance_id
# }

# module "clb_policy" {
#   source = "../../modules/alicloud/clb/acl"
#   env = local.env
#   project_name = local.project_name
#   acl_name = "all"
#   resource_group_id = module.resource.resource_group_id
#   acl_list = {
#     "0":["192.168.100.2/32","all"]
#   }
# }

# module "clb_server" {
#   source = "../../modules/alicloud/clb/server"
#   payment_type = "PayAsYouGo"
#   # payment_type = "Subscription"
#   project_name = local.project_name
#   env = local.env
#   clb_name = "app"
#   vswitch_id = module.vpc.vswitch_id[0]
#   load_balancer_spec = "slb.s1.small"
#   resource_group_id = module.resource.resource_group_id
#   internat_enable = true
#   clb_eip_bandwidth = 200
# }

# module "clb_group_n" {
#   source = "../../modules/alicloud/clb/target_ecs_n"
#   load_balancer_id  = module.clb_server.clb_id
#   server_group_name = "test"
#   group_port        = "22"
#   listen_port       = "22"
#   listen_protocol   = "tcp"
#   server_num        = 2
#   server_id         = module.ecs.instance_id
#   acl_status        = "on"
#   acl_type          = "white"
#   acl_id            = module.clb_policy.acl_id
# }

# module "clb_group_a" {
#   source = "../../modules/alicloud/clb/target_ecs_a"
#   load_balancer_id  = module.clb_server.clb_id
#   server_group_name = "test"
#   group_port        = "22"
#   listen_port       = "443"
#   listen_protocol   = "https"
#   server_num        = 2
#   server_id         = module.ecs.instance_id
#   acl_status        = "on"
#   acl_type          = "white"
#   acl_id            = module.clb_policy.acl_id
#   server_certificate_id = "1102317278539235_18fe75cdbc6_-273595215_1919659152"
#   health_check      = "on"
# }

locals {
  env          = "test"
  project_name = "alicloud-demo-test"
}