# Terraform State Setup

More specifics to these steps found in `../../modules/aws-terraform-backend`

- Update backend reference so we can init without a backend to avoid a chicken/egg problem. I have decided to put backend information in the `versions.tf` for logical organization, but where you decide to put your backend block is up to you.

```bash

  # backend "s3" {
  #   bucket         = var.s3_backend_bucket
  #   dynamodb_table = var.dynamodb_lock_table_name
  #   encrypt        = true
  #   key            = "states/terraform.tfstate"
  #   region         = var.aws_region
  # }
```

- Init without the backend reference.

```bash
## INIT
terraform init -backend=false
```

- Plan and review.

```bash
## PLAN

terraform plan -out=backend.plan -target=module.backend -var 's3_backend_bucket=some-tf-backend-state'
```

- Apply that plan.

```bash
## APPLY

terraform apply backend.plan
```

- Update backend to point to newly created s3 bucket. Again, this block can be where you would like. I have it in `versions.tf`

```bash
  backend "s3" {
    bucket         = "some-tf-backend-state"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    key            = "states/terraform.tfstate"
    region         = "some-aws-region"
  }
```

- Reconfigure to move state to the new backend. You will be asked to migrate the state into this backend. If done correctly, after responding `yes` your state should now be in the s2 bucket.

```bash
## RECONFIGURE

terraform init -reconfigure
```

- Validate resource against the backend statefile.

```bash
## VALIDATE RESOURCES

terraform plan
#################################
## EXPECTED:
#################################
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```
