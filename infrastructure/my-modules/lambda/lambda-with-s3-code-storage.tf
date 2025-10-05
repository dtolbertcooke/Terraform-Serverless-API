# Create a lambda function with code stored in S3

# Upload the local .zip file into the bucket
resource "aws_s3_object" "lambda_zip" {
  bucket = var.bucket_name
  key    = "fruit-api-${var.method}.zip"
  source = "${path.root}/../../../app/handlers/fruit-api-${var.method}.zip"                     # local path to your zip
  etag   = try(filemd5("${path.root}/../../../app/handlers/fruit-api-${var.method}.zip"), null) # triggers re-upload if file changes
}

# Lambda function
resource "aws_lambda_function" "rest_api" {
  function_name    = "fruit-api-${var.method}-${var.environment}"
  role             = var.lambda_exec_role_arn
  s3_bucket        = var.bucket_name
  s3_key           = aws_s3_object.lambda_zip.key
  handler          = "handler.handler"
  source_code_hash = aws_s3_object.lambda_zip.etag # ensures lambda is updated if zip file changes
  runtime          = "nodejs22.x"

  memory_size = 256 # Good default for lightweight APIs, small to medium JSON, and DynamoDB reads/writes; not too expensive
  timeout     = 10  # helps prevent runaway executions and controls costs

  environment {
    variables = {
      DYNAMODB_TABLE = "${var.dynamodb_table_name}-${var.environment}"
    }
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}