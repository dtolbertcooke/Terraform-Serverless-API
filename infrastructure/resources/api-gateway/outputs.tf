output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}

output "resource_path" {
  value = aws_api_gateway_resource.api_resource_fruits.path
}