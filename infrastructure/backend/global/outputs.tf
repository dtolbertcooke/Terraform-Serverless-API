output "github_actions_policy_arn" {
  value = aws_iam_policy.github_actions_policy.arn
}
output "state_bucket_name" {
  value = module.s3_backend.bucket_name
}
output "lambda_code_bucket_dev_name" {
  value = module.lambda_code_bucket_dev.bucket_name
}
output "lambda_code_bucket_test_name" {
  value = module.lambda_code_bucket_test.bucket_name
}
output "lambda_code_bucket_prod_name" {
  value = module.lambda_code_bucket_prod.bucket_name
}
output "state_table_name" {
  value = module.dynamodb_backend.state_table_name
}
output "github_oidc_provider_arn" {
  value = module.github_oidc_provider.oidc_provider_arn
}
output "region" {
  value = var.region
}
