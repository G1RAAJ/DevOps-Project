variable "aws_region" {
  default = "ap-south-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI ID"
  default     = "ami-0f5ee92e2d63afc18"  # Ubuntu 22.04 LTS (Mumbai example)
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "devops"
}

