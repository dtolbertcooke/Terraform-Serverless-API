output "api_gateway_access_log_group_arn" {
  value = aws_cloudwatch_log_group.api_access_logs.arn
}