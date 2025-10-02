# remote state is populated by the script in .github/workflows/terraform.yml
terraform {
  backend "s3" {
  }
}