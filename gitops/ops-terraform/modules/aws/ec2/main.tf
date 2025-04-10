resource "aws_instance" "ec2" {
  count                       = var.instance_num 
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  subnet_id                   = var.ec2_subnet_public ? var.public_subnet_id[count.index % length(var.public_subnet_id)] : var.private_subnet_id[count.index % length(var.private_subnet_id)]
  key_name                    = var.key_name
  vpc_security_group_ids      = var.vpc_security_group_ids

  root_block_device {
    volume_size               = var.ebs_volume_root_size
    volume_type               = var.ebs_volume_type
    delete_on_termination     = true
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = var.ebs_volume_type
      volume_size           = ebs_block_device.value.volume_size
      delete_on_termination = true
    }
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
    Name          = "${var.env}-${var.project_name}-${var.instance_name}-${count.index + 1}"
    Environment   = var.env
    Project       = var.project_name
  }

  tags = {
    Name          = "${var.env}-${var.project_name}-${var.instance_name}-${count.index + 1}"
    Environment   = var.env
    Project       = var.project_name
  }
}

resource "aws_eip" "instance_eip" {
  count          = var.ec2_subnet_public ? var.instance_num : 0
  instance       = aws_instance.ec2[count.index].id
  tags = {
     Name        = "${var.env}-${var.project_name}-${var.instance_name}-${count.index + 1}-eip"
     Environment = var.env
     Project     = var.project_name
   }
}