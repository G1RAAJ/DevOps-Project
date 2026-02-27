# Create 3 EC2 instances with one region and multi packages in different evironments.
provider "aws" {
  region = "ap-south-1"
}

locals {
  servers = {
    prod_web = {
      ami           = "ami-03f4878755434977f"   # Amazon Linux
      instance_type = "t3.micro"
      user_data     = <<-EOF
                        #!/bin/bash
                        yum update -y
                        yum install -y nginx

                        # Production hardening
                        systemctl enable nginx
                        systemctl start nginx
                        firewall-cmd --permanent --add-service=http
                        firewall-cmd --reload

                        echo "<h1>Production Web Server</h1>" > /usr/share/nginx/html/index.html
                        EOF
    }

    staging_app = {
      ami           = "ami-0f5ee92e2d63afc18"   # Ubuntu
      instance_type = "t3.small"
      user_data     = <<-EOF
                        #!/bin/bash
                        apt update -y
                        apt install -y apache2 php

                        systemctl enable apache2
                        systemctl start apache2

                        # Enable debug mode (staging only)
                        echo "display_errors = On" >> /etc/php/8.1/apache2/php.ini
                        systemctl restart apache2

                        echo "<h1>Staging App Server</h1>" > /var/www/html/index.html
                        EOF
    }

    dev_data = {
      ami           = "ami-0a2b6a8a1a5f7c1a2"   # RHEL
      instance_type = "t3.medium"
      user_data     = <<-EOF
                        #!/bin/bash
                        yum update -y
                        yum install -y python3 git

                        echo "Dev Data Server Ready" > /home/ec2-user/dev.txt
                        EOF
    }
  }
}

resource "aws_instance" "servers" {
  for_each      = local.servers
  ami           = each.value.ami
  instance_type = each.value.instance_type
  key_name      = "your-key-name"

  user_data = each.value.user_data

  tags = {
    Name        = each.key
    Environment = split("_", each.key)[0]
    Role        = split("_", each.key)[1]
  }
}
