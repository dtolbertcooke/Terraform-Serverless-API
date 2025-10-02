variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "dev"
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
variable "lambda_uri_GET" {
  description = "Lambda function URI for GET method"
  type        = string
}
variable "lambda_uri_PUT" {
  description = "Lambda function URI for PUT method"
  type        = string
}
variable "lambda_uri_PATCH" {
  description = "Lambda function URI for PATCH method"
  type        = string
}
variable "lambda_uri_DELETE" {
  description = "Lambda function URI for DELETE method"
  type        = string
}
variable "lambda_uri_GET_ID" {
  description = "Lambda function URI for GET by id method"
  type        = string
}
variable "api_gateway_role_arn" {
  description = "ARN of the IAM role for API Gateway to push logs to CloudWatch"
  type        = string
}