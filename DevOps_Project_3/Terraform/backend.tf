terraform {
  backend "s3" {
    bucket = "amzn-ec2-eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
