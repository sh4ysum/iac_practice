#################################
## TERRAFORM 
#################################
terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0, <= 5.54.1" ## VERSION PIN OR NOT TO PIN, UP TO YOU
    }
  }
  backend "s3" {
    bucket         = "some-tf-backend-state"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    key            = "states/terraform.tfstate"
    region         = "some-aws-region"
  }
}

#################################
## AWSPROVIDER
#################################
provider "aws" {
  region = var.aws_region
}
