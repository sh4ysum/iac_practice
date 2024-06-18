#################################
## Defaults
#################################
variable "aws_client_name" {
  description = "Client name/account used in naming. Recomment two or three characters. Usually a prefix for resource naming"
  type        = string
  default     = ""
}

variable "aws_environment" {
  description = "Environment name"
  type        = string
  default     = ""
}

variable "stack" {
  description = "Project stack name. Recommend three characters"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

#################################
## DynamoDB
#################################
variable "dynamodb_lock_table_enabled" {
  description = "Affects aws-terraform-backend module behavior. Set to false or 0 to prevent this module from creating the DynamoDB table to use for terraform state locking and consistency. More info on locking for aws/s3 backends: https://www.terraform.io/docs/backends/types/s3.html. More information about how terraform handles booleans here: https://www.terraform.io/docs/configuration/variables.html"
  type        = bool
  default     = true
}

variable "dynamodb_lock_table_hash_key" {
  description = "Hash key name for terraform state locking."
  type        = string
  default     = "LockID"
}

variable "dynamodb_lock_table_hash_key_type" {
  description = "(Required) Attribute type. Valid values are S (string), N (number), B (binary)."
  type        = string
  default     = "S"
}

variable "dynamodb_lock_table_name" {
  description = "(Required) Unique within a region ; name of the table."
  type        = string
  default     = "terraform-lock"
}

variable "dynamodb_lock_table_stream_enabled" {
  description = "(Optional) Whether Streams are enabled."
  type        = bool
  default     = false
}

variable "dynamodb_lock_table_stream_view_type" {
  description = "(Optional) When an item in the table is modified, StreamViewType determines what information is written to the table's stream. Valid values are KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "dynamodb_lock_table_read_capacity" {
  description = "(Optional) Number of read units for this table. If the billing_mode is PROVISIONED, this field is required."
  type        = number
  default     = 1
}

variable "dynamodb_lock_table_write_capacity" {
  description = "(Optional) Number of write units for this table. If the billing_mode is PROVISIONED, this field is required."
  type        = number
  default     = 1
}

#################################
## S3 Variables
#################################
variable "s3_backend_bucket" {
  description = "(Optional, Forces new resource) Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here. The name must not be in the format [bucket_name]--[azid]--x-s3. Use the aws_s3_directory_bucket resource to manage S3 Express buckets."
  type        = string
  default     = ""
}

variable "s3_kms_master_key_id" { # DEFAULT TO ABSENT/BLANK TO USE THE DEFAULT AWS/S3 AWS KMS MASTER KEY
  description = "(Optional) AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. The default aws/s3 AWS KMS master key is used if this element is absent while the sse_algorithm is aws:kms."
  type        = string
  default     = ""
}

variable "s3_sse_algorithm" {
  description = "(Required) Server-side encryption algorithm to use. Valid values are AES256, aws:kms, and aws:kms:dsse"
  type        = string
  default     = "AES256"
}
