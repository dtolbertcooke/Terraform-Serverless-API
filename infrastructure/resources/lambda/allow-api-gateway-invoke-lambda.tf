resource "aws_lambda_permission" "allow_apigw_invoke_GET" {
  statement_id  = "AllowGETExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_GET_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/GET${var.path}"
}
# GET by id
resource "aws_lambda_permission" "allow_apigw_invoke_GET_ID" {
  statement_id  = "AllowGETIDExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_GET_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/GET${var.path}/*"
}

resource "aws_lambda_permission" "allow_apigw_invoke_PUT" {
  statement_id  = "AllowPUTExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_PUT_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/PUT${var.path}"
}

resource "aws_lambda_permission" "allow_apigw_invoke_PATCH" {
  statement_id  = "AllowPATCHExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_PATCH_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/PATCH${var.path}/*"
}

resource "aws_lambda_permission" "allow_apigw_invoke_DELETE" {
  statement_id  = "AllowDELETEExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_DELETE_function
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.api_execution_arn}/*/DELETE${var.path}/*"
}
