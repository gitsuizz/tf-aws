
resource "aws_vpc" "example_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.example_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-subnet-1"
    SubnetType = "PublicSubnet"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count                     = length(var.private_subnet_cidrs)
  vpc_id                    = aws_vpc.example_vpc.id
  cidr_block                = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
    SubnetType = "PrivateSubnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "${var.name_prefix}-internet-gateway"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route Table - Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "${var.name_prefix}-public-route-table"
  }
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public_subnet_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}
