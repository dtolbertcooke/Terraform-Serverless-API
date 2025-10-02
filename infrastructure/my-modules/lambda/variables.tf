variable "method" {
  description = "HTTP method for the API (e.g. GET, PATCH, PUT, DELETE)"
  type        = string
}
variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "dev"
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
variable "lambda_exec_role_arn" {
  description = "ARN of the lambda execution role"
  type        = string
}
variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for app data"
  type        = string
}