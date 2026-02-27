variable "aws_region" {
  default = "us-east-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 AMI"
  default     = "ami-0b6c6ebed2801a5cb" # N verginia ami
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name"
  default     = "devops"
}

variable "cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "public_1"{
  description = "Public subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "public_2"{
  description = "Public subnet CIDR block"
  default     = "10.0.2.0/24"
}

variable "private_1"{
  description = "Private subnet CIDR block"
  default     = "10.0.3.0/24"
}

variable "private_2"{
  description = "Private subnet CIDR block"
  default     = "10.0.4.0/24"
}
