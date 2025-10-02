variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
variable "lambda_code_bucket_name" {
  description = "Name of the S3 bucket for lambda code"
  type        = string
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform locks"
  type        = string
}
variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "test"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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
variable "GET_method" {
  description = "HTTP GET method for the API"
  type        = string
  default     = "GET"
}
variable "PUT_method" {
  description = "HTTP PUT method for the API"
  type        = string
  default     = "PUT"
}
variable "PATCH_method" {
  description = "HTTP PATCH method for the API"
  type        = string
  default     = "PATCH"
}
variable "DELETE_method" {
  description = "HTTP DELETE method for the API"
  type        = string
  default     = "DELETE"
}
variable "app_db_hash_key" {
  description = "Hash key for the application DynamoDB table"
  type        = string
}
variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "test"
}
