provider "aws" {
  region = "cn-north-1"
}

terraform {
  backend "s3" {
    dynamodb_table = "vevor-terraform-state-lock"
    bucket         = "vevor-terraform-remote-state"
    key            = "projects/aws-demo-test/terraform.tfstate"
    region         = "cn-north-1"
    encrypt        = true
  }
}

module "vpc" {
  source                        = "../../modules/aws/vpc/vpc_full"

  env                           = local.env
  project_name                  = local.project_name
  vpc_cidr_block                = "172.16.0.0/16"
  subnet_cidr_blocks_public     = ["172.16.0.0/20", "172.16.16.0/20","172.16.32.0/20"]
  subnet_cidr_blocks_private    = ["172.16.48.0/20", "172.16.64.0/20","172.16.80.0/20"]
}

module "prefix_list" {
  source = "../../modules/aws/security_group/prefix_list"

  env                    = local.env
  project_name           = local.project_name
  prefix_name            = "demo"
  prefix_list_entries    = {
   "0": ["192.168.0.1/32","test01"]
   "1": ["192.168.0.2/32","test02"]
   "2": ["192.168.0.3/32","test03"]
  }
}

module "ec2_sg" {
  source                        = "../../modules/aws/security_group/sg_options"

  env                           = local.env
  project_name                  = local.project_name
  sg_name                       = "ec2-app"
  vpc_id                        = module.vpc.vpc_id

  inbound_rules = {
    #"key" = [ "protocol", "from_port", "to_port", "cidr|sg|self|pl", "destination", "description" ]
    "0" = [ "tcp", "80", "80", "cidr", "0.0.0.0/0", "-" ]
    #"1" = [ "tcp", "443", "443","sg", "sg-0e2b58c9f32a67994", "-" ]
    "2" = [ "tcp", "22", "22", "self", true, "-" ]
    "3" = [ "tcp", "22", "22", "pl", "pl-62a5400b", "-" ]
    "4" = [ "tcp", "81", "81", "cidr", "1.1.1.1/32", "-" ]
    "5" = [ "tcp", "81", "81", "cidr", "1.1.1.2/32", "-" ]
    "6" = [ "tcp", "81", "81", "cidr", "1.1.1.3/32", "-" ]
    "7" = [ "tcp", "22", "22", "cidr", "0.0.0.0/0", "-" ]
  }
  outbound_rules = {
    "0" = [ "tcp", "80", "80", "cidr", "0.0.0.0/0", "-" ]
    #"1" = [ "tcp", "443", "443","sg", "sg-0e2b58c9f32a67994", "-" ]
    "2" = [ "tcp", "22", "22", "self", true, "-" ]
    "3" = [ "tcp", "22", "22", "pl", "pl-62a5400b", "-" ]
    "4" = [ "all", "0", "0", "cidr", "0.0.0.0/0", "-" ]
  }
}


module "key_pair" {
  source                        = "../../modules/aws/key_pair/generate_key"

  env                           = local.env
  project_name                  = local.project_name
  #public_key                    = file("~/.ssh/id_rsa.pub")
  private_key                   = pathexpand("~/.ssh/${local.project_name}-${local.env}-private.pem")
}

data "aws_ami" "amzn2_x86_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [ "amzn2-ami-kernel*-gp2" ]
  }
  filter {
    name   = "architecture"
    values = [ "x86_64" ]
  }
}

# module "ebs_snapshot_policy" {
#   source       = "../../modules/aws/lifecycle_policy"
#   env          = local.env
#   project_name = local.project_name
#   # state        = "DISABLED"  #默认参数开启 ENABLED
#   target_tags = { Environment = "test" }
# }

module "ec2_app" {
  source                        = "../../modules/aws/ec2"
  instance_num                 = 1

  env                           = local.env
  project_name                  = local.project_name
  instance_name                 = "app"
  instance_ami                  = data.aws_ami.amzn2_x86_latest.id
  instance_type                 = "t3.medium"
  ebs_volume_root_size          = 40
  ebs_volume_type               = "gp3"
  ec2_subnet_public             = true
  public_subnet_id              = module.vpc.public_subnet_id
  private_subnet_id             = module.vpc.private_subnet_id
  key_name                      = module.key_pair.key_name
  vpc_security_group_ids        = [module.ec2_sg.ec2_sg_id]
  additional_ebs_volumes        = [{
    device_name = "/dev/sdh"
    volume_size = 50
  }]

  user_data                     = templatefile("../../modules/aws/ec2/middleware_docker.tftpl", {
    git_token                   = "agp_cfdxxxxxxxxxxxxxxxxxxxxx"
    start_services             = ["nginx","openjdk-8u332-slim"]
    acr_region                  = "cn-shanghai"
    mount_data_dir              = "/data"
  })
}

module "ec2_middlware" {
  source                        = "../../modules/aws/ec2"
  instance_num                 = 1

  env                           = local.env
  project_name                  = local.project_name
  instance_name                 = "middlware"
  instance_ami                  = data.aws_ami.amzn2_x86_latest.id
  instance_type                 = "t3.xlarge"
  ebs_volume_root_size          = 40
  ebs_volume_type               = "gp3"
  ec2_subnet_public             = true
  public_subnet_id              = module.vpc.public_subnet_id
  private_subnet_id             = module.vpc.private_subnet_id
  key_name                      = module.key_pair.key_name
  vpc_security_group_ids        = [module.ec2_sg.ec2_sg_id]
  additional_ebs_volumes        = [{
    device_name = "/dev/sdh"
    volume_size = 50
  }]

  user_data                     = templatefile("../../modules/aws/ec2/middleware_docker.tftpl", {
    git_token                   = "agp_cfdxxxxxxxxxxxxxxxxxxxxx"
    start_services              = ["mysql","redis","elasticsearch","rabbitmq-3.7.28","kafka","zookeeper","apollo","canal","nacos","rocketmq","mongo"]
    acr_region                  = "cn-shanghai"
    mount_data_dir              = "/data"
  })
}

#module "alb_https" {
#  source                        = "../../modules/aws/alb_https"
#
#  env                           = local.env
#  project_name                  = local.project_name
#  internal                      = false
#  enable_deletion_protection    = false
#  vpc_id                        = module.vpc.vpc_id
#  public_subnet_id              = module.vpc.public_subnet_id
#  private_subnet_id             = module.vpc.private_subnet_id
#  security_groups               = [module.ec2_sg.ec2_sg_id]
#  ssl_certificate_arn           = "arn:aws-cn:acm:cn-north-1:475810397983:certificate/c3daf9e0-92e1-4048-a354-a8f58907001c"
#  target_type                   = "instance"
#  target_group_port             = "80"
#  target_group_protocol         = "HTTP"
#  listenr_path_pattern          = ["/*"]
#  listenr_host_header           = ["www.example.com"]
#  target_instance_id            = module.ec2_app.instance_id
#}

# module "nlb_security_group" {
#   source       = "../../modules/aws/security_group/full"
#   sg_name      = "nlb"
#   env          = local.env
#   project_name = local.project_name
#   vpc_id       = module.vpc.vpc_id
#   ingress_rules = [{
#     from_port       = 80
#     to_port         = 80
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#     security_groups = []
#     self            = false
#     prefix_list_ids = []
#     description     = "allow 22"
#   }]
#   egress_rules = [{
#     from_port       = 0
#     to_port         = 0
#     protocol        = "-1"
#     cidr_blocks     = ["0.0.0.0/0"]
#     security_groups = []
#     self            = false
#     prefix_list_ids = []
#     description     = "allow nat"
#   }]

# }
# module "nlb_server" {
#   source         = "../../modules/aws/nlb/nlb_server"
#   env            = local.env
#   lb_name        = "lihaifeng"
#   internal       = false
#   subnets        = module.vpc.public_subnet_id
#   project_name   = local.project_name
#   security_group = [module.security_group_lb.security_groups_id]

# }

# module "nlb_target_group" {
#   source                       = "../../modules/aws/nlb/nlb_target_group"
#   target_group_name            = "tcp-80"
#   target_group_health_port     = 80
#   target_group_port            = 80
#   target_group_health_protocol = "TCP"
#   target_group_protocol        = "TCP"
#   instance_id                  = module.ec2_app.instance_id
#   vpc_id                       = module.vpc.vpc_id
#   project_name                 = local.project_name
#   listener_port                = 80
#   listener_protocol            = "TCP"
#   aws_lb_id                    = module.nlb_server.load_balancer_id
# }

locals {
  env               = "test"
  project_name      = "aws-demo"
}