# Create AWS 3 EC2 instances with all network resources with same region but different values along with specific software packages.
provider "aws" {
  region = "ap-south-1"
}

# ---------------- VPC ----------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "custom-vpc" }
}

# ---------------- Subnets ----------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"
  tags = { Name = "private-subnet" }
}

# ---------------- IGW ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# ---------------- NAT ----------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
}

# ---------------- Route Tables ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR-IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------- Web Server (PROD - Public) ----------------
resource "aws_instance" "web" {
  ami                         = "ami-03f4878755434977f" # Amazon Linux
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  associate_public_ip_address = true
  key_name                    = "your-key-name"

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y nginx
                systemctl enable nginx
                systemctl start nginx
                echo "Production Web Server" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name        = "web-server"
    Environment = "prod"
  }
}

# ---------------- App Server (STAGING - Private) ----------------
resource "aws_instance" "app" {
  ami                    = "ami-0f5ee92e2d63afc18" # Ubuntu
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  key_name               = "your-key-name"

  user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install -y apache2 php
                systemctl enable apache2
                systemctl start apache2
                echo "Staging App Server" > /var/www/html/index.html
              EOF

  tags = {
    Name        = "app-server"
    Environment = "staging"
  }
}

# ---------------- Data Server (DEV - Private) ----------------
resource "aws_instance" "data" {
  ami                    = "ami-0a2b6a8a1a5f7c1a2" # RHEL
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  key_name               = "your-key-name"

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y python3
                echo "Dev Data Server Ready" > /home/ec2-user/dev.txt
              EOF

  tags = {
    Name        = "data-server"
    Environment = "dev"
  }
}
