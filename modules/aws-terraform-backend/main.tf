#################################
## MODULE: aws-terraform-backend
#################################
#
#   Bootstrap your terraform backend on AWS:
#   This template creates and/or manages the following resources:
#     - An S3 Bucket for storing terraform state
#     - An S3 Bucket for storing logs from the state bucket
#     - A DynamoDB table to be used for state locking and consistency
#  
#   The DynamoDB state locking table is optional: 
#   to disable set the 'dynamodb_lock_table_enabled' variable to false.
#   For more info on how terraform handles boolean variables:
#   https://www.terraform.io/docs/configuration/variables.html
#
#################################

#################################
## DYNAMODB FOR STATE LOCKING
#################################
resource "aws_dynamodb_table" "tf_backend_state_lock_table" {
  count            = var.dynamodb_lock_table_enabled ? 1 : 0
  name             = var.dynamodb_lock_table_name
  read_capacity    = var.dynamodb_lock_table_read_capacity
  write_capacity   = var.dynamodb_lock_table_write_capacity
  hash_key         = var.dynamodb_lock_table_hash_key
  stream_enabled   = var.dynamodb_lock_table_stream_enabled
  stream_view_type = var.dynamodb_lock_table_stream_enabled ? var.dynamodb_lock_table_stream_view_type : ""

  attribute {
    name = var.dynamodb_lock_table_hash_key
    type = var.dynamodb_lock_table_hash_key_type
  }

  tags = merge(local.defaults_tags, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

#################################
## S3 BUCKETS
#################################
## S3 BUCKET FOR STATE
resource "aws_s3_bucket" "tf_backend_bucket" {
  bucket = var.s3_backend_bucket

  tags = merge(local.defaults_tags, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

## S3 BUCKET FOR LOGS
resource "aws_s3_bucket" "tf_backend_bucket_logs" {
  bucket = "${var.s3_backend_bucket}-logs"

  tags = merge(local.defaults_tags, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

## LOGGING FOR STATE BUCKET
resource "aws_s3_bucket_logging" "tf_backend_bucket_logging" {
  bucket = aws_s3_bucket.tf_backend_bucket.id

  target_bucket = aws_s3_bucket.tf_backend_bucket_logs.id
  target_prefix = "logs/"
}

## DATA FOR POLICY
data "aws_iam_policy_document" "tf_backend_bucket_policy" {
  statement { ## REQUIRE ENCRYPTED TRANSPORT
    sid    = "RequireEncryptedTransport"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.tf_backend_bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        false,
      ]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }

  statement { ## REQUIRE ENCRYPTED STORAGE
    sid    = "RequireEncryptedStorage"
    effect = "Deny"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.tf_backend_bucket.arn}/*",
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values = [
        var.s3_kms_master_key_id == "" ? var.s3_sse_algorithm : "aws:kms",
      ]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

## POLICY FOR STATE BUCKET
resource "aws_s3_bucket_policy" "tf_backend_bucket_policy" {
  bucket = aws_s3_bucket.tf_backend_bucket.id
  policy = data.aws_iam_policy_document.tf_backend_bucket_policy.json
}


## SERVER SIDE ENCRYPTION FOR STATE BUCKET
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_bucket_encryption" {
  bucket = aws_s3_bucket.tf_backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_kms_master_key_id
      sse_algorithm     = var.s3_kms_master_key_id == "" ? var.s3_sse_algorithm : "aws:kms"
    }
  }
}

## SERVER SIDE ENCRYPTION FOR LOG BUCKET
resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend_bucket_logs_encryption" {
  bucket = aws_s3_bucket.tf_backend_bucket_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.s3_kms_master_key_id
      sse_algorithm     = var.s3_kms_master_key_id == "" ? var.s3_sse_algorithm : "aws:kms"
    }
  }
}

## VERSIONING FOR STATE BUCKET
resource "aws_s3_bucket_versioning" "tf_backend_bucket_versioning" {
  bucket = aws_s3_bucket.tf_backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

## VERSIONING FOR LOG BUCKET
resource "aws_s3_bucket_versioning" "tf_backend_bucket_logs_versioning" {
  bucket = aws_s3_bucket.tf_backend_bucket_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
