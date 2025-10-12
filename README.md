# Serverless API (Terraform + GitHub Actions + AWS)

This project demonstrates how to build and deploy a **serverless REST API** on AWS using **Infrastructure as Code (Terraform)** and a **CI/CD pipeline (GitHub Actions with OIDC)**.

---

## Architecture

**High-Level Flow:**

1. **Terraform** → IaC to provision infrastructure
2. **Remote Backend** → Terraform state stored in **S3**, with state locking via **DynamoDB**
3. **CI/CD** → GitHub Actions with **OIDC role assumption** (no static AWS creds)
4. **API Gateway** → entrypoint for HTTP/S requests
5. **Lambda (Node.js)** → serverless application logic
6. **DynamoDB** → NoSQL database to persist application data

See [`Architecture.md`](./Architecture.md) for diagrams and details.

---

## Repository Structure

```bash
.
├── .github/workflows/                    # GitHub Actions pipelines
│   ├── terraform-pipeline.yml
│   ├── bootstrap-pipeline.yml
│   ├── destroy.yml
├── app/
│   ├── handlers/                         # Lambda source code for CRUD functionality
│   ├── tests/                            # jest unit tests for node.js lambda functions
│   ├── eslint.config.mjs
│   ├── jest.config.js
│   ├── package-lock.json
│   └── package.json
├── docs/
│   ├── Architecture.md                   # Architecture documentation
│   ├── architecture-diagram.png          # Architecture diagram
│   └── ADRs/                             # Architecture Decision Records
│       ├── ADR-001-State-Management.md
│       ├── ADR-002-OIDC-Auth.md
│       ├── ADR-003-CI-CD.md
│       └── ADR-004-IAM-Design.md
├── infrastructure/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── remote-state.tf
│   ├── variables.tf
│   └── backend/global/                   # global configuration for each environment
│       ├── global-infra.tfvars
│       ├── global.tf
│       ├── outputs.tf
│       └── variables.tf
│   ├── env/                              # configuration for each environment
│       ├── dev.yml
│       ├── test.yml
│       └── prod.yml
│   ├── my-modules/
│       ├── dynamodb/
│       ├── iam/
│       ├── lambda/
│   ├── resources/
│       ├── api-gateway/
│       ├── iam/
│       ├── lambda/
│       ├── s3/
├── README.md
└── LICENSE

```

## Prerequisites

- AWS Account with permissions to create IAM, S3, DynamoDB, API Gateway, Lambda.
- Terraform v1.12.2+
- Repo-level secrets for GitHub Actions

## Setup

1. Bootstrap Remote Backend

- run bootstrap-global.yml workflow

**This creates:**

- S3 bucket for Terraform state
- S3 bucket for lambda source code (one per environment)
- DynamoDB table for state locking
- IAM role/policy/provider for GitHub OIDC

2. Deploy Serverless API

- run serverless-api.yml workflow

## CI/CD Workflow

1. Manually run bootstrap-global.yml **once** to initialize backend.
2. Build terraform infrastructure for serverless api

- On push to main:

  - GitHub Actions authenticates to AWS via OIDC
  - Runs tests on lambda code and terraform configuration
  - On approval (global-infra / prod branches) → terraform apply

- On pull requests:

  - Runs plans for review

Workflow config: .github/workflows/serverless-api.yml

## Documentation

- Architecture.md → diagrams & design
- ADRs → key architectural decisions

## Testing

- Unit tests for Node.js Lambda functions (jest).
- Pipeline validates Terraform (terraform fmt, validate, plan).

## Security Best Practices

- No static AWS credentials → OIDC used for GitHub Actions.
- Least privilege IAM roles.
- Remote state with locking (S3 + DynamoDB).
- Parameters stored in AWS SSM Parameter Store
- Secrets stored in GitHub Actions secrets.

## Observability

- CloudWatch logs for Lambda + API Gateway.
- DynamoDB metrics in CloudWatch.

## Future Improvements

- Expand ADRs (observability, cost optimization, auth).
- Add custom domain + HTTPS (ACM + API Gateway).
- Add monitoring dashboards (CloudWatch Dashboards / Grafana).
- Add monitoring with CloudWatch + X-Ray.
- Add custom domain.
- Add AWS secrets management (AWS Secrets Manager).
- Add integration tests in CI/CD pipeline.

## See also

- [Terraform VPC](https://github.com/dtolbertcooke/Terraform-VPC-Infrastructure/)

## Author

Doug Tolbert-Cooke.
