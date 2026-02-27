# Terraform configuration for AWS EC2 instance and S3 backend
# Create manually S3 bucket "my-terraform-state-jeevan" in us-east-1 region before running terraform apply
terraform {
  backend "s3" {
    bucket  = "my-terraform-state-jeevan"
    key     = "ec2/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
    region = var.aws_region
}

resource "aws_security_group" "web_sg" {
  name = "web-sg"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "ubuntu_web" {
  ami           = "var.ami_id"  # N. verginia
  instance_type = "t2.micro"
  key_name      = "var.key_name"

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "Ubuntu-Web"
  }
}
