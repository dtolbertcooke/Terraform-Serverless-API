locals {
  config = yamldecode(file("${path.module}/env/${var.environment}.yml"))
}

# remote state for global backend to get lambda code bucket names
data "terraform_remote_state" "global" {
  backend = "s3"
  config = {
    bucket = local.config.state_bucket_name
    key    = "global/terraform.tfstate"
    region = local.config.region
  }
}

# app resources (lambda execution role, api-gateway role, lambda functions, dynamodb table, rest api)
# 1. dynamodb table for app
module "app_db" {
  source                         = "./my-modules/dynamodb"
  dynamodb_table_name            = local.config.dynamodb_table_name
  billing_mode                   = "PROVISIONED" # required for autoscaling
  environment                    = local.config.environment
  project_name                   = local.config.project_name
  owner                          = local.config.owner
  hash_key                       = local.config.app_db_hash_key
  enable_autoscaling             = true
  autoscaling_min_capacity       = 3
  autoscaling_max_capacity       = 10
  autoscaling_target_utilization = 70
}

# 2. lambda execution role for all lambda functions
module "lambda_exec_role" {
  source               = "./resources/iam/lambda-exec-role"
  environment          = local.config.environment
  region               = local.config.region
  aws_account_id       = local.config.aws_account_id
  dynamodb_table_name  = local.config.dynamodb_table_name
  GET_function_name    = module.lambda_GET_function.lambda_function_name
  PUT_function_name    = module.lambda_PUT_function.lambda_function_name
  PATCH_function_name  = module.lambda_PATCH_function.lambda_function_name
  DELETE_function_name = module.lambda_DELETE_function.lambda_function_name
}

# 3.1. GET function
module "lambda_GET_function" {
  source               = "./my-modules/lambda"
  method               = local.config.api_methods.GET
  environment          = local.config.environment
  project_name         = local.config.project_name
  owner                = local.config.owner
  lambda_exec_role_arn = module.lambda_exec_role.lambda_exec_role_arn
  bucket_name          = data.terraform_remote_state.global.outputs.lambda_code_bucket_dev_name
  dynamodb_table_name  = local.config.dynamodb_table_name
}

# 3.2. PUT function
module "lambda_PUT_function" {
  source               = "./my-modules/lambda"
  method               = local.config.api_methods.PUT
  environment          = local.config.environment
  project_name         = local.config.project_name
  owner                = local.config.owner
  lambda_exec_role_arn = module.lambda_exec_role.lambda_exec_role_arn
  bucket_name          = data.terraform_remote_state.global.outputs.lambda_code_bucket_dev_name
  dynamodb_table_name  = local.config.dynamodb_table_name
}

# 3.3. PATCH function
module "lambda_PATCH_function" {
  source               = "./my-modules/lambda"
  method               = local.config.api_methods.PATCH
  environment          = local.config.environment
  project_name         = local.config.project_name
  owner                = local.config.owner
  lambda_exec_role_arn = module.lambda_exec_role.lambda_exec_role_arn
  bucket_name          = data.terraform_remote_state.global.outputs.lambda_code_bucket_dev_name
  dynamodb_table_name  = local.config.dynamodb_table_name
}

# 3.4. DELETE function
module "lambda_DELETE_function" {
  source               = "./my-modules/lambda"
  method               = local.config.api_methods.DELETE
  environment          = local.config.environment
  project_name         = local.config.project_name
  owner                = local.config.owner
  lambda_exec_role_arn = module.lambda_exec_role.lambda_exec_role_arn
  bucket_name          = data.terraform_remote_state.global.outputs.lambda_code_bucket_dev_name
  dynamodb_table_name  = local.config.dynamodb_table_name
}

# 4. api gateway role
module "api_gateway_role" {
  source      = "./resources/iam/api-gateway-role"
  environment = local.config.environment
}

# 5. api gateway
module "rest_api" {
  source               = "./resources/api-gateway"
  environment          = local.config.environment
  project_name         = local.config.project_name
  owner                = local.config.owner
  lambda_uri_GET       = module.lambda_GET_function.lambda_function_arn
  lambda_uri_GET_ID    = module.lambda_GET_function.lambda_function_arn
  lambda_uri_PUT       = module.lambda_PUT_function.lambda_function_arn
  lambda_uri_PATCH     = module.lambda_PATCH_function.lambda_function_arn
  lambda_uri_DELETE    = module.lambda_DELETE_function.lambda_function_arn
  api_gateway_role_arn = module.api_gateway_role.api_gateway_role_arn
}

# 6. api gateway invoke lambda permission
module "apigw_invoke_lambda_permission" {
  source                 = "./resources/lambda"
  api_execution_arn      = module.rest_api.api_gateway_execution_arn
  lambda_PUT_function    = module.lambda_PUT_function.lambda_function_name
  lambda_GET_function    = module.lambda_GET_function.lambda_function_name
  lambda_PATCH_function  = module.lambda_PATCH_function.lambda_function_name
  lambda_DELETE_function = module.lambda_DELETE_function.lambda_function_name
  path                   = module.rest_api.resource_path
}
