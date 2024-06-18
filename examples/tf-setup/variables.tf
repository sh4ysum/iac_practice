#################################
## S3
#################################

variable "s3_backend_bucket" {
  description = "(Optional, Forces new resource) Name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here. The name must not be in the format [bucket_name]--[azid]--x-s3. Use the aws_s3_directory_bucket resource to manage S3 Express buckets."
  type        = string
  default     = ""
}
