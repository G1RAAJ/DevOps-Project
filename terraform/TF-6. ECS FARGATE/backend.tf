terraform {
  backend "s3" {
    bucket         = "ecs-fargate-terraform-state-jeevan-bucket"
    key            = "ecs-fargate/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table" # give this line only on real production environment or remove it for testing purpose. if not removed, then give on CLI "terraform plan/apply -lock=false"
  }
}
