output "api_gateway_log_group_arn" {
  value = aws_cloudwatch_log_group.api_logs.arn # update this
}