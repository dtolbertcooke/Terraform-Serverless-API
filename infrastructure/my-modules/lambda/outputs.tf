output "lambda_function_arn" {
  value = aws_lambda_function.rest_api.arn
}
output "lambda_function_name" {
  value = aws_lambda_function.rest_api.function_name
}