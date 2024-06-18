# aws-terraform-backend

A Terraform module which enables you to create and manage your [Terraform AWS Backend resources](https://www.terraform.io/docs/backends/types/s3.html), _with terraform_ to achieve a best practice setup.

This template creates and/or manages the following resources:

- An S3 Bucket for storing terraform state
- An S3 Bucket for storing logs from the state bucket
- A DynamoDB table to be used for state locking and consistency

## Bootstrapping your project

This terraform module helps you bootstrap any project which uses terraform for infrastructure management.

**_Why does this exist?_**

One of the most popular backend options for terraform is AWS (S3 for state, and DynamoDB for the lock table). If your project [specifies an AWS/S3 backend](https://www.terraform.io/docs/backends/types/s3.html), Terraform requires the existence of an S3 bucket in which to store _state_ information about your project, and a DynamoDB table to use for locking (this prevents you, your collaborators, and CI from stepping on each other with terraform commands which either modify your state or the infrastructure itself).

This terraform module creates/manages those resources:

- Versioned S3 bucket for state
- Properly configured DynamoDB lock table

### Avoid the Chicken & Egg Problem

In order to bootstrap your project with this module/setup, you will need to wait until **after** Step 4 (below) to write your [terraform backend block](https://developer.hashicorp.com/terraform/language/settings/backends/configuration#using-a-backend-block) into one of your `.tf` files. (Your "terraform configuration block" is the one that looks like this `terraform {}`.)

If you are updating an existing terraform-managed project, or you already wrote your `terraform {...}` block into one of your `.tf` files, you will run into an initialization error on Step 3 (`terraform plan`):

### Writing Your Terraform Configuration

https://www.terraform.io/docs/configuration/terraform.html

You can write your terraform config into one of your `.tf` files. Otherwise you'll end up needing to provide the `-backend-config` [parameters partial configuration](https://www.terraform.io/docs/backends/config.html#partial-configuration) every single time you run `terraform init` (which might be often).

I have put it in the `versions.tf` to organize my terraform block and providers in a single place.

```bash

## TERRAFORM
terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50.0, <= 5.54.1" ## PIN OR NOT TO PIN, UP TO YOU
    }
  }
  backend "s3" {
    bucket         = var.s3_backend_bucket
    dynamodb_table = var.dynamodb_lock_table_name
    encrypt        = true
    key            = "states/terraform.tfstate"
    region         = var.aws_region
  }
}

## PROVIDER
provider "aws" {
  region = var.aws_region
}

```

### Let's Init!

The following commands _should_ get you up and running:

```bash
## STEP 1:
## Download modules
terraform get -update

## STEP 2:
## Initialize your directory/project for use with terraform.
## The use of -backend=false here is important: it avoids backend configuration
## on our first call to init since we haven't created our backend resources yet.
terraform init -backend=false

## STEP 3:
# Create infrastructure plan for just the tf backend resources.
# Target only the resources needed for our aws backend for terraform state/locking.
terraform plan -out=backend.plan -target=module.backend -var 's3_backend_bucket=YOUR-BUCKET-NAME-HERE'

## STEP 4:
## Apply the infrastructure plan
terraform apply backend.plan

## STEP 5:
## Only after applying (building) the backend resources, uncomment our terraform config in the versions.tf file.
## Please see "writing your terraform configuration" below for more info.

  backend "s3" {
    bucket         = var.s3_backend_bucket
    dynamodb_table = var.dynamodb_lock_table_name
    encrypt        = true
    key            = "states/terraform.tfstate"
    region         = var.aws_region
  }

## STEP 6:
## Reinitialize terraform to use your newly provisioned backend.
terraform init -reconfigure
  > yes

## STEP 7:
## Validate your backend to current resource code.
terraform plan

#################################
## EXPECTED:
#################################
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed
```
