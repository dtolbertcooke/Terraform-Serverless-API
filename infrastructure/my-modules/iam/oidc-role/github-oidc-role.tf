# OIDC IAM Role for GitHub Actions (per environment)
# assumes role via the OIDC provider defined in oidc-provider.tf
resource "aws_iam_role" "github_actions" {
  name = "github-oidc-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "${var.oidc_provider_arn}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # restrict to repository + environment
            "token.actions.githubusercontent.com:sub" = "repo:${var.repository}:environment:${var.environment}"
          }
        }
      }
    ]
  })
}