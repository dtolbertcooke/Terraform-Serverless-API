# ADR 1: Infrastructure as Code Tool - Terraform

## Status

Accepted

## Context

We need a consistent, version controlled way to provision and manage AWS infrastructure across multiple environments (dev, test, prod). The chosen Infrastructure ad Code (IaC) tool should enable reproducable deployments, simplify drift detection, support modularity, policy enforcement, team collaboration, CI/CD integration and integrate with our existing AWS environment.

## Decision

We will use **Terraform** as our IaC tool.

### Reasoning:

- Cloud Agnostic: Supports AWS and other cloud providers.

- Declarative Syntax: HashiCorp Configuration Language (HCL) makes configurations readable, maintainable, and easy to review.

- Strong Ecosystem: Thousands of providers and modules available via the Terraform Registry.

- Predictable Workflow: The plan/apply lifecycle ensures visibility and control before any changes are made.

- Reusable Modules: Encourages DRY (Don’t Repeat Yourself) patterns and scalable infrastructure design.

- CI/CD Integration: Easily integrates with GitHub Actions, and other pipelines for automated deployments.

- Widespread Adoption: Large community and strong documentation ensure longterm support.

## Alternative Consideration

### AWS CloudFormation

- Pros: Native AWS integration drift detection
- Cons: AWS only; verbose syntax; less modular than Terraform
- Why rejected: Used less than Terraform; verbose syntax

### AWS CDK

- Pros: Native AWS integration; define infrastructure programmatically
- Cons: AWS only; adds layer of complexity
- Why rejected: Preferred a declarative tool that didn't add unnecesary programattic complexity

## Consequences

**Pros**

- Declarative syntax (HCL)
- Multi-cloud flexibility
- Reusable modular design
- Large support system
- Simple integration into CI/CD and policy enforcement workflows
  **Cons**
- Learning curve for HCL and Terraform concepts
- Requires remote state management configuration for collaboration

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform)
- [Terraform vs AWS CloudFormation](https://spacelift.io/blog/terraform-vs-cloudformation)
