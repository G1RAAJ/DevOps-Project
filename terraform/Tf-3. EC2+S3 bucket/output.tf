# output
output "instance_public_ip" {
  value = aws_instance.ubuntu_web.public_ip
}

