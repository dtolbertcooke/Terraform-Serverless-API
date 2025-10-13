# set api gateway role for logs
resource "aws_api_gateway_account" "api_gateway_role" {
  cloudwatch_role_arn = var.api_gateway_role_arn
}

# create access logging for api
# creates the CloudWatch log group that receives API Gateway access logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/apigw/fruits-api-access-logs-${var.environment}"
  retention_in_days = 14 # make configurable via a variable (7 for dev, 30 for prod)
}
# create api gateway stage
# defines the access log format and destination for api 
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = var.environment
  rest_api_id   = var.rest_api_id            # aws_api_gateway_rest_api.rest_api.id
  deployment_id = var.rest_api_deployment_id # aws_api_gateway_deployment.api_deployment.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId    = "$context.requestId",
      ip           = "$context.identity.sourceIp",
      requestTime  = "$context.requestTime",
      httpMethod   = "$context.httpMethod",
      resourcePath = "$context.resourcePath",
      status       = "$context.status",
      responseTime = "$context.responseLatency",
      protocol     = "$context.protocol"
    })
  }
  # visualize request traces in AWS X-Ray
  xray_tracing_enabled = true # make configurable via a variable (true for prod, false for dev & test)
  depends_on           = [aws_api_gateway_account.api_gateway_role]
}
# Full Request and Response Logs
resource "aws_api_gateway_method_settings" "path_specific" {
  rest_api_id = var.rest_api_id # aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO" # enables detailed execution logging
    metrics_enabled    = true   # publishes API Gateway metrics to CloudWatch
    data_trace_enabled = true   # logs full request/response payloads (useful in dev/test, disable in prod for cost/security)
  }
}