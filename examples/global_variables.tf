#################################
## GLOBAL VARIABLES
#################################

variable "aws_client_name" {
  description = "Client name/account used in naming. Recomment two or three characters. Usually a prefix for resource naming"
  type        = string
  default     = "your-client-name-here"
}

variable "aws_region" {
  description = "Region"
  type        = string
  default     = "your-region-here"
}

variable "aws_environment" {
  description = "Project environment"
  type        = string
  default     = "your-environment-here"
}

variable "default_tags" {
  description = "Default tags specified in locals.tf"
  type        = map(string)
  default     = {}
}

variable "stack" {
  description = "Project stack name. Recommend three characters"
  type        = string
  default     = "your-stack-here"
}
