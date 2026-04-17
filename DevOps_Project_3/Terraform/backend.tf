

terraform {
  backend "s3" {
    bucket = "amzn-ec2-eks"
    key = "eks/ngg_cluster_name/statefile"
    region = "us-east-1"
  }
} 
