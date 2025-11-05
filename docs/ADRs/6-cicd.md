# ADR 6: CI/CD Tool – GitHub Actions

## Status

Accepted

## Context

We need a CI/CD tool to automate the deployment of our Terraform infrastructure and serverless application code. The tool should integrate well with our GitHub repository, support Infrastructure as Code workflows, and be cost effective for our use case.

## Decision

We will use **GitHub Actions** as our CI/CD Tool.

### Reasoning:

- Native GitHub Integration: Seamlessly integrates with our existing GitHub repositories for easy workflow triggers on code changes.

- Cost Efficiency: Free for public repositories and includes a generous free tier for private repositories, making it cost effective for our needs.

- Infrastructure as Code Support: Excellent support for Terraform and other IaC tools through pre built actions and community maintained workflows.

- Marketplace of Actions: Extensive library of pre-built actions available in the GitHub Marketplace to simplify common CI/CD tasks.

Security with OIDC: Supports OpenID Connect (OIDC) for secure, short lived authentication to AWS without storing long lived secrets.

Visibility & Collaboration: Built-in logs, artifact storage, and status checks integrate with pull requests for clear feedback

## Alternative Consideration

### Jenkins

- Pros: Highly customizable; large plugin ecosystem
- Cons: Requires server management; more complex setup and maintenance
- Why rejected: Higher operational overhead compared to GitHub Actions

### GitLab CI

- Pros: Integrated with GitLab repositories; good CI/CD features; Docker integration
- Cons: Native only to GitLab; may require additional configuration
- Why rejected: Preferred native GitHub integration for our repositories

### CircleCI

- Pros: Easy to set up; good performance for CI/CD pipelines
- Cons: Additional cost for larger teams; less native GitHub integration
- Why rejected: Cost and integration considerations made GitHub Actions a better fit

## Consequences

**Pros**

- Native GitHub integration
- Cost effective for our use case
- Strong IaC support
- Extensive marketplace of actions
- Secure authentication with OIDC
- Built in visibility and collaboration features

**Cons**

- Limited to GitHub repositories
- Learning curve for GitHub Actions syntax and concepts

## References

- [GitHub Actions Documentation - Infrastructure as Code](https://docs.github.com/en/actions/deployment/deploying-to-your-cloud-provider)
- [CI/CD Platform Comparison - DevOps Institute](https://shubzz.hashnode.dev/comparing-cicd-giants-github-actions-vs-gitlab-ci-vs-circleci-vs-jenkins-pipeline)
