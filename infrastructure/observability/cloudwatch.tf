# api gateway role for logs
resource "aws_api_gateway_account" "api_gateway_role" {
  cloudwatch_role_arn = var.api_gateway_role_arn
}

# create access logs group for api
resource "aws_cloudwatch_log_group" "api_access_logs" {
  name              = "/apigw/fruits-api-access-logs-${var.environment}"
  retention_in_days = var.environment == "prod" ? 14 : 7 # longer retention for prod

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# create execution logs group for api (API Gateway uses this exact naming pattern)
resource "aws_cloudwatch_log_group" "api_execution_logs" {
  name              = "API-Gateway-Execution-Logs_${var.rest_api_id}/${var.environment}"
  retention_in_days = var.environment == "prod" ? 14 : 7 # longer retention for prod

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# create api gateway stage
# defines the access log format and destination for api 
resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = var.environment
  rest_api_id   = var.rest_api_id
  deployment_id = var.rest_api_deployment_id

  # send access logs to cloudwatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_access_logs.arn
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
  xray_tracing_enabled = var.environment == "prod" ? true : false
  depends_on           = [aws_api_gateway_account.api_gateway_role]
}

# Method-Level Logging and Metrics
resource "aws_api_gateway_method_settings" "path_specific" {
  rest_api_id = var.rest_api_id
  stage_name  = aws_api_gateway_stage.api_stage.stage_name
  method_path = "*/*"

  settings {
    logging_level = "INFO" # enables execution logging
    # logging_level      = var.environment == "prod" ? "ERROR" : "INFO"
    metrics_enabled    = true                                     # publishes API gateway metrics to cloudwatch
    data_trace_enabled = var.environment == "prod" ? false : true # logs full request/response payloads (useful in dev/test, disable in prod for cost/security)
  }

  # Ensure execution log group exists before enabling logging
  depends_on = [aws_cloudwatch_log_group.api_execution_logs]
}

# Log groups for lambda functions
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each = var.api_methods

  name              = "/aws/lambda/fruit-api-${each.value}-${var.environment}"
  retention_in_days = var.environment == "prod" ? 14 : 7 # longer retention for prod

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# # cloudwatch dashboard for api gateway, lambda and dynamodb metrics
# resource "aws_cloudwatch_dashboard" "api_dashboard" {
#   dashboard_name = "serverless-api-${var.environment}-dashboard"
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type = "metric",
#         x    = 0, y = 0, width = 12, height = 6,
#         properties = {
#           metrics = [
#             ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.get.name],  # ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.get.name],
#             ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.get.name] # ["AWS/Lambda", "Duration", "FunctionName", aws_lambda_function.get.name]
#           ],
#           period = 300,
#           stat   = "Sum",
#           region = var.region,
#           title  = "Lambda Errors and Duration"
#         }
#       }
#     ]
#   })
# }

# example 
resource "aws_cloudwatch_dashboard" "example" {
  dashboard_name = "serverless-api-${var.environment}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-012345"
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.region
          title  = "EC2 Instance CPU"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
}