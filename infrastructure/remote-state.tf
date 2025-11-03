# remote state is populated by the script in .github/workflows/serverless-api.yml
terraform {
  backend "s3" {
  }
}