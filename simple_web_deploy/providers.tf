// this section declares which cloud provider we are going to use.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = var.terraform_user_profile
  region  = var.aws_region

  default_tags {
    tags = {
      Environment = terraform.workspace
    }
  }
}