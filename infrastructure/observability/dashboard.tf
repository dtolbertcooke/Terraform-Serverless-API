
# cloudwatch dashboard for api gateway, lambda and dynamodb metrics
resource "aws_cloudwatch_dashboard" "api_dashboard" {
  dashboard_name = "serverless-api-${var.environment}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      # API Gateway 4xx and 5xx errors
      {
        type   = "metric"
        x      = 0 # x coordinate
        y      = 0 # y coordinate
        width  = 12
        height = 6

        properties = {
          title = "Fruit API 4XX and 5XX Errors"
          metrics = [
            ["AWS/ApiGateway", "4XXError", "ApiId", var.rest_api_id, "Stage", var.environment], 
            [".", "5XXError", ".", ".", ".", "."]                                               
          ]
          period = 300
          view   = "timeSeries"
          stat   = "Sum"
          region = var.region
        }
      },
      # Lambda errors and duration
      {
        type   = "metric"
        x      = 0 # x coordinate
        y      = 6 # y coordinate
        width  = 12
        height = 6

        properties = {
          title = "Lambda Errors and Duration"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name], 
            [".", "Duration", ".", "."]                                         
          ],
          period = 300
          view   = "timeSeries"
          stat   = "Sum"
          region = var.region
        }
      },
      # DynamoDB read/write capacity units
      {
        type   = "metric"
        x      = 12 # x coordinate
        y      = 0  # y coordinate
        width  = 12
        height = 6

        properties = {
          title = "DynamoDB Read/Write Capacity Units"
          metrics = [
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name],
            [".", "ConsumedWriteCapacityUnits", ".", "."]
          ],
          period = 300
          view   = "timeSeries"
          stat   = "Sum"
          region = var.region
        }
      }
    ]
  })
}