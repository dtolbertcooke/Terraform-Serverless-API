variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
  default     = "dev"
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