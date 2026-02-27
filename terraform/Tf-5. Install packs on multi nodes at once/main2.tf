# 3 regions, 3 instances with different values and specific software packages like Nginx, apache2 Python.
# ---------------- Providers ----------------

provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

provider "aws" {
  alias  = "eu_north"
  region = "eu-north-1"
}

provider "aws" {
  alias  = "ap_south"
  region = "ap-south-1"
}

# ---------------- Server Definitions ----------------

locals {
  servers = {
    web = {
      region        = "us_east"
      ami           = "ami-0c02fb55956c7d316" # Amazon Linux us-east-1
      instance_type = "t3.micro"
      environment   = "prod"
      user_data     = <<-EOF
                        #!/bin/bash
                        yum update -y
                        yum install -y nginx
                        systemctl enable nginx
                        systemctl start nginx
                        echo "Production Web - us-east-1" > /usr/share/nginx/html/index.html
                      EOF
    }

    app = {
      region        = "eu_north"
      ami           = "ami-08eb150f611ca277f" # Ubuntu eu-north-1
      instance_type = "t3.small"
      environment   = "staging"
      user_data     = <<-EOF
                        #!/bin/bash
                        apt update -y
                        apt install -y apache2 php
                        systemctl enable apache2
                        systemctl start apache2
                        echo "Staging App - eu-north-1" > /var/www/html/index.html
                      EOF
    }

    data = {
      region        = "ap_south"
      ami           = "ami-0f5ee92e2d63afc18" # RHEL/Ubuntu ap-south-1 (update if needed)
      instance_type = "t3.medium"
      environment   = "dev"
      user_data     = <<-EOF
                        #!/bin/bash
                        yum update -y
                        yum install -y python3
                        echo "Dev Data - ap-south-1" > /home/ec2-user/dev.txt
                      EOF
    }
  }
}

# ---------------- Resource Blocks ----------------

resource "aws_instance" "servers" {
  for_each = local.servers

  provider = aws[each.value.region]

  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = "your-key-name"

  user_data = each.value.user_data

  tags = {
    Name        = "${each.key}-server"
    Role        = each.key
    Environment = each.value.environment
    Region      = each.value.region
  }
}
