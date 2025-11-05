# global resources for all environments

# state bucket
module "s3_backend" {
  source       = "../../resources/s3"
  bucket_name  = var.state_bucket_name
  environment  = var.environment
  project_name = var.project_name
  owner        = var.owner
}

# lambda code buckets dev
module "lambda_code_bucket_dev" {
  source       = "../../resources/s3"
  bucket_name  = var.lambda_code_bucket
  environment  = "dev"
  project_name = var.project_name
  owner        = var.owner
}

# lambda code buckets test
module "lambda_code_bucket_test" {
  source       = "../../resources/s3"
  bucket_name  = var.lambda_code_bucket
  environment  = "test"
  project_name = var.project_name
  owner        = var.owner
}

# lambda code buckets prod
module "lambda_code_bucket_prod" {
  source       = "../../resources/s3"
  bucket_name  = var.lambda_code_bucket
  environment  = "prod"
  project_name = var.project_name
  owner        = var.owner
}

# locking table
module "dynamodb_backend" {
  source              = "../../my-modules/dynamodb"
  dynamodb_table_name = var.state_table_name
  billing_mode        = "PAY_PER_REQUEST"
  environment         = var.environment
  project_name        = var.project_name
  owner               = var.owner
  hash_key            = var.backend_db_hash_key
  enable_autoscaling  = false
}

# OIDC provider for github actions
module "github_oidc_provider" {
  source = "../../my-modules/iam/oidc-provider"
}

# OIDC policy to be used by all (dev, test, prod) github oidc roles
resource "aws_iam_policy" "github_actions_policy" {
  name = "github-oidc-role-main-terraform-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowCreateLambdaFunctions"
        Effect   = "Allow"
        Action   = "lambda:CreateFunction"
        Resource = "*"
      },
      {
        Sid    = "AllowRegisterScalableTarget"
        Effect = "Allow"
        Action = [
          "application-autoscaling:RegisterScalableTarget",
          "application-autoscaling:PutScalingPolicy",
          "application-autoscaling:DeleteScalingPolicy",
          "application-autoscaling:DescribeScalingPolicies",
          "application-autoscaling:DescribeScalableTargets",
          "application-autoscaling:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowPassLambdaExecutionRole"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "arn:aws:iam::${var.aws_account_id}:role/lambda-execution-role-*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },
      {
        Sid    = "AllowPassRoles"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          "arn:aws:iam::${var.aws_account_id}:role/apigw-cloudwatch-logs-role-global-infra",
          "arn:aws:iam::${var.aws_account_id}:role/apigw-cloudwatch-logs-role-dev",
          "arn:aws:iam::${var.aws_account_id}:role/apigw-cloudwatch-logs-role-test",
          "arn:aws:iam::${var.aws_account_id}:role/apigw-cloudwatch-logs-role-prod",
          "arn:aws:iam::${var.aws_account_id}:role/lambda-execution-role-dev",
          "arn:aws:iam::${var.aws_account_id}:role/lambda-execution-role-test",
          "arn:aws:iam::${var.aws_account_id}:role/lambda-execution-role-prod"
        ]
      },
      {
        Sid    = "AllowLambdaFunctions"
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:GetFunction",
          "lambda:DeleteFunction",
          "lambda:GetPolicy",
          "lambda:ListVersionsByFunction",
          "lambda:GetFunctionCodeSigningConfig",
          "lambda:AddPermission",
          "lambda:TagResource"
        ]
        Resource = [
          "arn:aws:lambda:${var.region}:${var.aws_account_id}:function:fruit-api-GET*",
          "arn:aws:lambda:${var.region}:${var.aws_account_id}:function:fruit-api-PUT*",
          "arn:aws:lambda:${var.region}:${var.aws_account_id}:function:fruit-api-PATCH*",
          "arn:aws:lambda:${var.region}:${var.aws_account_id}:function:fruit-api-DELETE*"
        ]
      },
      {
        Sid      = "AllowCreateDynamoDBTable"
        Effect   = "Allow"
        Action   = ["dynamodb:CreateTable"]
        Resource = "*"
        Condition = {
          StringLike = {
            "dynamodb:TableName" = [
              "fruit-api-lock-table-*",
              "fruit-api-table-*"
            ]
          }
        }
      },
      {
        Sid    = "AllowPDynamoDB"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DeleteItem",
          "dynamodb:TagResource",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:ListTagsOfResource"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.region}:${var.aws_account_id}:table/fruit-api-lock-table-${var.environment}",
          "arn:aws:dynamodb:${var.region}:${var.aws_account_id}:table/fruit-api-table-*"
        ]
      },
      {
        Sid    = "AllowTerraformS3StateBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:GetEncryptionConfiguration",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketPublicAccessBlock",
          "s3:GetReplicationConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetBucketWebsite",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketLogging",
          "s3:GetBucketCORS",
          "s3:GetBucketAcl",
          "s3:GetAccelerateConfiguration",
          "s3:GetObjectTagging",
        ]
        Resource = [
          "arn:aws:s3:::${module.s3_backend.bucket_name}",
          "arn:aws:s3:::${module.s3_backend.bucket_name}/*",
          "arn:aws:s3:::${module.lambda_code_bucket_dev.bucket_name}",
          "arn:aws:s3:::${module.lambda_code_bucket_dev.bucket_name}/*",
          "arn:aws:s3:::${module.lambda_code_bucket_test.bucket_name}",
          "arn:aws:s3:::${module.lambda_code_bucket_test.bucket_name}/*",
          "arn:aws:s3:::${module.lambda_code_bucket_prod.bucket_name}",
          "arn:aws:s3:::${module.lambda_code_bucket_prod.bucket_name}/*"
        ]
      },
      {
        Sid    = "AllowCreateS3Buckets"
        Effect = "Allow"
        Action = [
          "s3:CreateBucket",
          "s3:GetBucketLocation",
          "s3:HeadBucket",
          "s3:GetBucketTagging",
          "s3:PutBucketTagging",
          "s3:PutBucketAcl",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "CRUDAPIGateway"
        Effect = "Allow"
        Action = [
          "apigateway:PUT",
          "apigateway:POST",
          "apigateway:GET",
          "apigateway:PATCH",
          "apigateway:DELETE",
          "apigateway:TagResource"
        ]
        Resource = [
          "arn:aws:apigateway:${var.region}::/restapis",
          "arn:aws:apigateway:${var.region}::/restapis/*",
          "arn:aws:apigateway:${var.region}::/tags/*",
          "arn:aws:apigateway:${var.region}::/account"
        ]
      },
      {
        Sid    = "AllowLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutRetentionPolicy",
          "logs:DescribeLogGroups",
          "logs:ListTagsForResource",
          "logs:TagResource"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowIAMRoleManagement"
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:DetachRolePolicy",
          "iam:ListInstanceProfilesForRole",
          "iam:DeleteRole"
        ]
        Resource = ["arn:aws:iam::${var.aws_account_id}:role/*"]
      },
      {
        Sid    = "AllowIAMPolicyManagement"
        Effect = "Allow"
        Action = [
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:ListPolicyVersions"
        ]
        Resource = "arn:aws:iam::${var.aws_account_id}:policy/*"
      },
      {
        Sid      = "AllowIAMCreation"
        Effect   = "Allow"
        Action   = ["iam:CreateRole", "iam:CreatePolicy", "iam:CreateServiceLinkedRole"]
        Resource = "*"
      },
      {
        Sid    = "AllowSSMGetParameters"
        Effect = "Allow"
        Action = ["ssm:GetParameters", "ssm:GetParameter", "ssm:PutParameter", "ssm:DeleteParameter"]
        Resource = [
          "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/tf/*/backend/state-bucket",
          "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/tf/*/backend/state-table",
          "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/tf/*/backend/app-table",
          "arn:aws:ssm:${var.region}:${var.aws_account_id}:parameter/tf/*/backend/region"
        ]
      },
      {
        "Sid" : "CloudWatchDashboardAccess",
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:PutDashboard",
          "cloudwatch:GetDashboard",
          "cloudwatch:ListDashboards",
          "cloudwatch:DeleteDashboards"
        ],
        "Resource" : [
          "arn:aws:cloudwatch::${var.aws_account_id}:dashboard/serverless-api-dev-dashboard",
          "arn:aws:cloudwatch::${var.aws_account_id}:dashboard/serverless-api-test-dashboard",
          "arn:aws:cloudwatch::${var.aws_account_id}:dashboard/serverless-api-prod-dashboard"
        ]
      }
    ]
  })
}

# dev role
module "github_oidc_role_dev" {
  source            = "../../my-modules/iam/oidc-role"
  environment       = "dev"
  oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  repository        = var.repository
}

# test role
module "github_oidc_role_test" {
  source            = "../../my-modules/iam/oidc-role"
  environment       = "test"
  oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  repository        = var.repository
}

# prod role
module "github_oidc_role_prod" {
  source            = "../../my-modules/iam/oidc-role"
  environment       = "prod"
  oidc_provider_arn = module.github_oidc_provider.oidc_provider_arn
  repository        = var.repository
}

# Attach general policy to dev role
resource "aws_iam_role_policy_attachment" "github_actions_attach_dev" {
  role       = module.github_oidc_role_dev.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Attach general policy to test role
resource "aws_iam_role_policy_attachment" "github_actions_attach_test" {
  role       = module.github_oidc_role_test.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# Attach general policy to prod role
resource "aws_iam_role_policy_attachment" "github_actions_attach_prod" {
  role       = module.github_oidc_role_prod.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
