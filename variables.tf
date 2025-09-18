variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1" # or "us-gov-east-1" when targeting GovCloud
}

variable "aws_partition" {
  description = "The AWS partition to deploy resources in."
  type        = string
  default     = "aws"
}