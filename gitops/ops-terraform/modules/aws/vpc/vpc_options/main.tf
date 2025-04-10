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
    Name        = "${var.env}-${var.project_name}-igw-rt"
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

resource "aws_subnet" "private_subnet" {
  count                   = var.disable_enable_private_subnet ? length(var.subnet_cidr_blocks_private) : 0
  vpc_id                  = aws_vpc.default.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = var.subnet_cidr_blocks_private[count.index]

  tags = {
    Name = "${var.env}-${var.project_name}-${data.aws_availability_zones.available.names[count.index]}-private-subnet"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_route_table" "private_subnet_rt" {
  count = var.disable_enable_private_subnet ? 1 : 0
  vpc_id = aws_vpc.default.id

  tags   = {
    Name        = "${var.env}-${var.project_name}-private-rt"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_route_table_association" "default" {
  count          = length(var.subnet_cidr_blocks_public)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_vpc.default.default_route_table_id
}

resource "aws_route_table_association" "private_subnet_rt" {
  count          = var.disable_enable_private_subnet ? length(var.subnet_cidr_blocks_private) : 0
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_subnet_rt[0].id
}

resource "aws_eip" "nat_gateway_eip" {
  count          = var.disable_enable_nat_gateway ? 1 : 0

  tags = {
     Name        = "${var.env}-${var.project_name}-ngw-eip"
     Project     = var.project_name
     Environment = var.env
   }
}

# 创建单个nat网关
resource "aws_nat_gateway" "ngw" {
  count             = var.disable_enable_nat_gateway ? 1 : 0
  allocation_id     = aws_eip.nat_gateway_eip[0].id
  subnet_id         = aws_subnet.public_subnet[0].id
  connectivity_type = "public"
  
  tags = {
    Name        = "${var.env}-${var.project_name}-ngw"
    Project     = var.project_name
    Environment = var.env
  }
}

resource "aws_route" "private_route" {
  count                  = var.disable_enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_subnet_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}