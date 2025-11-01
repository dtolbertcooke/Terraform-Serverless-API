# ADR 2: Remote State Management – S3 + DynamoDB

## Status

Accepted

## Context

Terraform stores its state locally by default. When working in teams or CI/CD environments, using local state is unsafe and can lead to conflicts, overwrites, and drift. For team collaboration and CI/CD pipelines, we need a remote, centralized, and lockable backend to prevent conflicting updates.

## Decision

We will use an **S3 bucket** to store the Terraform state file and **DynamoDB** table for state locking to ensure consistency.

### Reasoning:

- Reliability and Availability: S3 provides durable, redundant storage, ensuring Terraform state is secured and recoverable.

- State Locking: Prevents concurrent terraform apply operations to avoid race conditions and corrupting the state file.

- Native Integration with AWS: No additional services or customization needed. Both are native AWS services with minimal maintenance.

- Cost Effective: Low cost for both S3 and DynamoDB.

- Security: Supports encryption at rest, versioning, and tailored IAM permissions for least privileged access.

- Standard Practice: The S3 / DynamoDB pattern is an industry standard setup and widely adopted across AWS environments.

- Ease of Automation: Seamlessly integrates with GitHub Actions, Terraform Cloud, and other CI/CD pipelines through IAM based authentication or GitHub OIDC roles.

## Alternative Consideration

### S3 Native State Locking

- Pros: Simplify architecture by no longer needing DynamoDB; built-in versioning
- Cons: Experimental; not ideal for collaboration; limited Terraform support
- Why rejected: It's not as robust as the traditional S3/DynamoDB setup which is still industry standard

### Terraform Cloud/Enterprise

- Pros: Easier setup; managed service with built-in state management; versioning; RBAC; policy enforcement
- Cons: Vendor lock in to HashiCorp; paid tier for advanced collaboration features
- Why rejected: Cost too high for my use case

### HashiCorp Consul

- Pros: Supports hybrid/multi-cloud; built-in locking; high availability
- Cons: Requires running and maintaining Consul clusters; adds operational complexity
- Why rejected: Operational complexity and more expensive than S3/DynamoDB setup

### Local state file

- Pros: Simple for testing
- Cons: no collaboration; high risk of state corruption
- Why rejected: Not viable for collaboration or production environment

## Consequences

**Pros**

- Declarative syntax (HCL)
- Reusable modular design
- Secure, cost effective, and reliable remote state management
- Prevents concurrent Terraform apply commands through DynamoDB locking
- Industry standard approach that simplifies initial setup and maintenance
- Works seamlessly with CI/CD and IAM based authentication
  **Cons**
- Slightly more initial setup than S3 Object Lock and Terraform Cloud (must configure S3 bucket and DynamoDB table)
- State file is limited to AWS region availability (though easily replicated)
- Manual management required for versioning and retention policies

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [Best Practices for Managing Terraform State](https://spacelift.io/blog/terraform-state#terraform-remote-state)
- [Terraform Remote State Documentation](https://developer.hashicorp.com/terraform/language/backend/s3)
