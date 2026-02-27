output "public_ip" {
  value = aws_instance.tform_web.public_ip
}

output "public_dns" {
  value = aws_instance.tform_web.public_dns
}
