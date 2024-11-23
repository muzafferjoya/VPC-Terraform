resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  count                  = length(var.public_subnet_cidr_blocks)
  vpc_id                 = aws_vpc.eks_vpc.id
  cidr_block             = element(var.public_subnet_cidr_blocks, count.index)
  availability_zone      = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = element(var.private_subnet_cidr_blocks, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "eks-private-subnet-${count.index + 1}"
  }
}

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "eks_internet_gateway" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_internet_gateway.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public_route_table_association" {
  count         = length(var.public_subnet_cidr_blocks)
  subnet_id     = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway for Private Subnets (optional for outgoing internet access)
resource "aws_nat_gateway" "eks_nat_gateway" {
  allocation_id = aws_eip.eks_nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "eks-nat-gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "eks_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

# Route Table for Private Subnets (routes traffic to NAT Gateway)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.eks_nat_gateway.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

# Associate Private Route Table with Private Subnets
resource "aws_route_table_association" "private_route_table_association" {
  count         = length(var.private_subnet_cidr_blocks)
  subnet_id     = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}
