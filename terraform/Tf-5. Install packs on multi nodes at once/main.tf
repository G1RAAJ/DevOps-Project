# one region, single instance with multiple software packages like Nginx, Python, Java, and PHP.
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "web" {
  ami           = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 Mumbai
  instance_type = "t2.micro"
  key_name      = "your-key-name"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y

              # Install Python
              sudo apt install -y python3 python3-pip

              # Install Java (OpenJDK 17)
              sudo apt install -y openjdk-17-jdk

              # Install Nginx
              sudo apt install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx

              # Install PHP
              sudo apt install -y php php-fpm

              # Create simple test page
              echo "<h1>Server Ready - Nginx + Python + Java + PHP Installed</h1>" | sudo tee /var/www/html/index.html

              EOF

  tags = {
    Name = "Multi-Package-Server"
  }
}

