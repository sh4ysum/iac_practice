locals {
  defaults_tags = {
    env    = var.aws_environment
    stack  = var.stack
    module = "aws-terraform-backend"
  }
}
