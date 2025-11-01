# ADR 3: Authentication for CI/CD – GitHub OIDC

## Status

Accepted

## Context

We need a secure, scalable way for our GitHub Actions CI/CD pipelines to authenticate with AWS to deploy infrastructure using Terraform. Authentication must avoid long lived credentials, follow the principle of least privilege permissions, and integrate seamlessly with our existing pipelines.

## Decision

We will use **GitHub OIDC (OpenID Connect)** with short lived AWS credentials for authentication in GitHub Actions pipelines.

### Reasoning:

- Short-Lived Credentials: OIDC provides temporary AWS credentials via AWS STS (Security Token Service), reducing the risk of compromised credentials compared to long lived IAM access keys.

- Security Best Practices: Aligns with AWS and GitHub recommendations for CI/CD authentication.

- No Secrets Management Required: Eliminates the need to store sensitive IAM access keys in GitHub Secrets.

- Granular Permissions: Roles can be scoped per repository, branch, or in our case environment using IAM permission policies and GitHub workflows.

- Seamless CI/CD Integration: Native support in GitHub Actions workflows; easy to configure Terraform to assume the role dynamically.

- Auditability: AWS CloudTrail shows which GitHub workflow assumed which role.

## Alternative Consideration

### IAM Access Keys

- Pros: Simple to configure; widely used method
- Cons: High security risk if keys are compromised; requires secret management; does not follow best practices for CI/CD (long lived keys)
- Why rejected: Security concerns outweigh simplicity; not aligned with modern CI/CD best practices.

### AWS Secrets Manager / HashiCorp Vault

- Pros: Centralized secret storage; supports secrets rotation and auditing
- Cons: Adds complexity to pipelines; still requires IAM credentials to access secrets
- Why rejected: Unnecessary complexity for our GitHub Actions pipelines when OIDC provides a native, simpler solution

## Consequences

**Pros**

- Eliminates the need for long lived IAM access keys
- Follows security best practices for CI/CD
- Simplifies secret management
- Supports fine grained access control per workflow
- Auditable via AWS CloudTrail
  **Cons**
- Requires configuring OIDC policies in IAM for each environment (dev, test, prod)
- Initial setup slightly more complex than storing access keys in GitHub Secrets

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [Terraform vs AWS CloudFormation](https://spacelift.io/blog/terraform-vs-cloudformation)
