# create rest api resource
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "Fruit-API-${var.environment}"
  description = "This is my Fruit API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}
# create api gateway resource
resource "aws_api_gateway_resource" "api_resource_fruits" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "fruits"
}
# create api gateway resource
resource "aws_api_gateway_resource" "api_resource_fruits_id" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_resource.api_resource_fruits.id
  path_part   = "{id}"
}
# create api gateway GET method
resource "aws_api_gateway_method" "api_method_GET" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource_fruits.id
  http_method   = "GET"
  authorization = "NONE"
}
# create api gateway PUT method
resource "aws_api_gateway_method" "api_method_PUT" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource_fruits.id
  http_method   = "PUT"
  authorization = "NONE"
}
# create api gateway GET by id method
resource "aws_api_gateway_method" "api_method_GET_ID" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method   = "GET"
  authorization = "NONE"
}
# create api gateway PATCH method
resource "aws_api_gateway_method" "api_method_PATCH" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method   = "PATCH"
  authorization = "NONE"
}
# create api gateway DELETE method
resource "aws_api_gateway_method" "api_method_DELETE" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method   = "DELETE"
  authorization = "NONE"
}
# create api gateway GET integration
resource "aws_api_gateway_integration" "api_integration_GET" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource_fruits.id
  http_method = aws_api_gateway_method.api_method_GET.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_uri_GET}/invocations"
}
# create api gateway PUT integration
resource "aws_api_gateway_integration" "api_integration_PUT" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource_fruits.id
  http_method = aws_api_gateway_method.api_method_PUT.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_uri_PUT}/invocations"
}
# create api gateway Get_ID integration
resource "aws_api_gateway_integration" "api_integration_GET_ID" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method = aws_api_gateway_method.api_method_GET_ID.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_uri_GET_ID}/invocations"
}
# create api gateway PATCH integration
resource "aws_api_gateway_integration" "api_integration_PATCH" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method = aws_api_gateway_method.api_method_PATCH.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_uri_PATCH}/invocations"
}
# create api gateway DELETE integration
resource "aws_api_gateway_integration" "api_integration_DELETE" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.api_resource_fruits_id.id
  http_method = aws_api_gateway_method.api_method_DELETE.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${var.lambda_uri_DELETE}/invocations"
}
# create api gateway deployment 
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.api_integration_GET,
    aws_api_gateway_integration.api_integration_PUT,
    aws_api_gateway_integration.api_integration_GET_ID,
    aws_api_gateway_integration.api_integration_PATCH,
    aws_api_gateway_integration.api_integration_DELETE
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
}

### moved to observability/cloudwatch.tf

# # set api gateway role for logs
# resource "aws_api_gateway_account" "api_gateway_role" {
#   cloudwatch_role_arn = var.api_gateway_role_arn
# }
#
# # create access logging for api
# # creates the CloudWatch log group that receives API Gateway access logs
# resource "aws_cloudwatch_log_group" "api_logs" {
#   name              = "/apigw/fruits-api-access-logs-${var.environment}"
#   retention_in_days = 14 # make configurable via a variable (7 for dev, 30 for prod)
# }
# # create api gateway stage
# # defines the access log format and destination for api 
# resource "aws_api_gateway_stage" "api_stage" {
#   stage_name    = var.environment
#   rest_api_id   = aws_api_gateway_rest_api.rest_api.id
#   deployment_id = aws_api_gateway_deployment.api_deployment.id

#   access_log_settings {
#     destination_arn = aws_cloudwatch_log_group.api_logs.arn
#     format = jsonencode({
#       requestId    = "$context.requestId",
#       ip           = "$context.identity.sourceIp",
#       requestTime  = "$context.requestTime",
#       httpMethod   = "$context.httpMethod",
#       resourcePath = "$context.resourcePath",
#       status       = "$context.status",
#       responseTime = "$context.responseLatency",
#       protocol     = "$context.protocol"
#     })
#   }
#   # visualize request traces in AWS X-Ray
#   xray_tracing_enabled = true # make configurable via a variable (true for prod, false for dev & test)
#   depends_on = [aws_api_gateway_account.api_gateway_role]
# }
# # Full Request and Response Logs
# resource "aws_api_gateway_method_settings" "path_specific" {
#   rest_api_id = aws_api_gateway_rest_api.rest_api.id
#   stage_name  = aws_api_gateway_stage.api_stage.stage_name
#   method_path = "*/*"

#   settings {
#     logging_level      = "INFO" # enables detailed execution logging
#     metrics_enabled    = true # publishes API Gateway metrics to CloudWatch
#     data_trace_enabled = true # logs full request/response payloads (useful in dev/test, disable in prod for cost/security)
#   }
# }