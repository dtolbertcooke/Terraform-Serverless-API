variable "region" {
  description = "AWS region"
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
  default     = "global-infra"
}
variable "state_bucket_name" {
  description = "The S3 bucket for terraform state files"
  type        = string
}
variable "lambda_code_bucket" {
  description = "The S3 bucket for lambda code zip files"
  type        = string
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "default_project"
}
variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "default_owner"
}
variable "backend_db_hash_key" {
  description = "Hash key for backend database"
  type        = string
  default     = "LockID"
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform locks"
  type        = string
}
variable "repository" {
  description = "GitHub repository name"
  type        = string
}