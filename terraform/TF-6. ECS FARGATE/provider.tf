terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.34.0" # check this command terraform providers before applying it.
    }
  }
}

provider "aws" {
  region = var.region
}
