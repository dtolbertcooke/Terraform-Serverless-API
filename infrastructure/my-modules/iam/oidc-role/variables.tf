variable "environment" {
  description = "Environment (dev, test, prod) for resources"
  type        = string
}
variable "repository" {
  description = "The repository"
  type        = string
}
variable "oidc_provider_arn" {
  description = "The ARN of the GitHub OIDC provider"
  type        = string
}