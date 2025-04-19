variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-east-1"  # Change as needed
}

variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state."
  type        = string
}

variable "lock_table_name" {
  description = "The name of the DynamoDB table for state locking."
  type        = string
}