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
variable "api_gateway_role_arn" {
  description = "ARN of the IAM role for API Gateway to push logs to CloudWatch"
  type        = string
}
variable "rest_api_id" {
  description = "ID of the API Gateway REST API"
  type        = string
}
variable "rest_api_deployment_id" {
  description = "ID of the API Gateway deployment"
  type        = string
}
variable "api_methods" {
  description = "Map of API methods for lambda log groups"
  type        = map(string)
}
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for the API"
  type        = string
}
variable "lambda_function_name" {
  description = "Name of the Lambda function(s) for monitoring"
  type        = string
}