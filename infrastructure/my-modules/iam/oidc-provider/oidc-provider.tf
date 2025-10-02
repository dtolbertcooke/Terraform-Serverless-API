# OIDC provider (only one per account / region needed, not per env)
resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com", # required - audience for OIDC provider
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1", # github OIDC root CA thumbprint
  ]
}