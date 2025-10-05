variable "api_execution_arn" {
  description = "The execution ARN of the REST API"
  type        = string
}
variable "lambda_GET_function" {
  description = "The Lambda function name for GET method"
  type        = string
}
variable "lambda_PUT_function" {
  description = "The Lambda function name for PUT method"
  type        = string
}
variable "lambda_PATCH_function" {
  description = "The Lambda function name for PATCH method"
  type        = string
}
variable "lambda_DELETE_function" {
  description = "The Lambda function name for DELETE method"
  type        = string
}
variable "path" {
  description = "The resource path in API Gateway"
  type        = string
}