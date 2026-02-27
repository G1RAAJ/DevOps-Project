# Terraform configuration for AWS VPC with public and private subnets, NAT Gateway, and EC2 instances
# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "tfrom_vpc" {
  cidr_block = var.cidr_block
  enable_dns_hostnames =  true
  tags = {
    Name = "tfrom_vpc"
  }
}

# Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.tfrom_vpc.id
  cidr_block              = var.public_1
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "public_subnet_1" }
}

# Public Subnet 2
resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc. tfrom_vpc.id
  cidr_block = var.public_2
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "public_subnet_2" }
}

# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id = aws_vpc.tfrom_vpc.id
  cidr_block = var.private_1
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = false
  tags = { Name = "private_subnet_1" }
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id = aws_vpc.tfrom_vpc.id
  cidr_block = var.private_2
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = false
  tags = { Name = "private_subnet_2" }
}

# Internet Gateway
resource "aws_internet_gateway" "tfrom_igw" {
  vpc_id = aws_vpc.tfrom_vpc.id
  tags = { Name = "tfrom_igw" }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tfrom_vpc.id
  
  route {
  cidr_block = "0.0.0/0"
  gateway_id = aws_internet_gateway.tfrom_igw.id
  }
  tags = { Name = "public_rt" }
}

# Public Route Table Association
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_2_assoc" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = { Name = "NAT-EIP" }
}

# NAT Gateway
resource "aws_nat_gateway" "tfrom_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1.id

  tags = { Name = "tfrom_nat" }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tfrom_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tfrom_nat.id
  }

  tags = { Name = "private_rt" }
}

# Private Route Table Association
resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}
resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.tfrom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "ubuntu_web" {
  count                       = 2
  ami                         = var.ami_id  
  instance_type               = var.instance_type    
  subnet_id                   = element (
                                 [aws_subnet.public_1.id,
                                  aws_subnet.public_2.id],
                                 count.index
                               )
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Ubuntu-Web-${count.index}"
  }
}


