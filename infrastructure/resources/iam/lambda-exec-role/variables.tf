variable "environment" {
  description = "The environment for the resources (e.g. dev, test, prod)"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for app data"
  type        = string
}
variable "GET_function_name" {
  description = "Name of the GET Lambda function"
  type        = string
}
variable "PUT_function_name" {
  description = "Name of the PUT Lambda function"
  type        = string
}
variable "PATCH_function_name" {
  description = "Name of the PATCH Lambda function"
  type        = string
}
variable "DELETE_function_name" {
  description = "Name of the DELETE Lambda function"
  type        = string
}
