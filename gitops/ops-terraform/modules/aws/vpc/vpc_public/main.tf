resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.env}-${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.env  
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name        = "${var.env}-${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.default.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-igw-route"
    Project     = var.project_name
    Environment = var.env
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.subnet_cidr_blocks_public)
  vpc_id                  = aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.subnet_cidr_blocks_public[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env}-${var.project_name}-${data.aws_availability_zones.available.names[count.index]}-public-subnet"
    Project     = var.project_name
    Environment = var.env
  }
}