# output
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.tfrom_vpc.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.tfrom_nat.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance in public subnet"
  value       = [ aws_instance.ubuntu_web[0].public_ip, aws_instance.ubuntu_web[1].public_ip ]
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance in private subnet"
  value       = [ aws_instance.ubuntu_web[1].private_ip, aws_instance.ubuntu_web[0].private_ip ]
}

