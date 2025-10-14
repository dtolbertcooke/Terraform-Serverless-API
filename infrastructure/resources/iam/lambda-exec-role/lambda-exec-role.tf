# IAM role for Lambda execution
data "aws_iam_policy_document" "lambda_dynamodb_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]
    resources = ["arn:aws:dynamodb:${var.region}:${var.aws_account_id}:table/${var.dynamodb_table_name}-${var.environment}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/*"
      # "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/${var.GET_function_name}-${var.environment}:*",
      # "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/${var.PUT_function_name}-${var.environment}:*",
      # "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/${var.PATCH_function_name}-${var.environment}:*",
      # "arn:aws:logs:${var.region}:${var.aws_account_id}:log-group:/aws/lambda/${var.DELETE_function_name}-${var.environment}:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name   = "lambda-dynamodb-policy-${var.environment}"
  policy = data.aws_iam_policy_document.lambda_dynamodb_policy_document.json
}
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-execution-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}
