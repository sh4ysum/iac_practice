## REFERENCE LOCAL MODULE
module "backend" {
  source = "../../modules/aws-terraform-backend"

  s3_backend_bucket = var.s3_backend_bucket
}
