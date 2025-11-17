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
variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}
variable "lambda_code_bucket_dev" {
  description = "Name of the dev env S3 bucket for Lambda code"
  type        = string
}
variable "lambda_code_bucket_test" {
  description = "Name of the test env S3 bucket for Lambda code"
  type        = string
}
variable "lambda_code_bucket_prod" {
  description = "Name of the prod env S3 bucket for Lambda code"
  type        = string
}