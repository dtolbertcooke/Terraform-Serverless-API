variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "dev"
}