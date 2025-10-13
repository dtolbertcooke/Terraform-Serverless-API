output "api_gateway_execution_arn" {
  value = aws_api_gateway_rest_api.rest_api.execution_arn
}
output "resource_path" {
  value = aws_api_gateway_resource.api_resource_fruits.path
}
# output rest api id
output "rest_api_id" {
  value = aws_api_gateway_rest_api.rest_api.id
}
# output rest api deployment id
output "rest_api_deployment_id" {
  value = aws_api_gateway_deployment.api_deployment.id
}