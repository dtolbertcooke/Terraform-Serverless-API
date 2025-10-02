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
├── .github/
│   └── workflows/                        # GitHub Actions pipelines
│       └── ci-cd.yml
├── app
│   ├── handlers                          # Lambda source code for CRUD functionality
│   │   ├── fruit-api-DELETE
│   │   │   ├── app.js
│   │   │   ├── handler.js
│   │   │   └── Makefile
│   │   ├── fruit-api-GET
│   │   │   ├── app.js
│   │   │   ├── handler.js
│   │   │   └── Makefile
│   │   ├── fruit-api-PATCH
│   │   │   ├── app.js
│   │   │   ├── handler.js
│   │   │   └── Makefile
│   │   ├── fruit-api-PUT
│   │   │   ├── app.js
│   │   │   ├── handler.js
│   │   │   └── Makefile
│   ├── tests                            # jest unit tests for node.js lambda functions
│   │   ├── delete.test.js
│   │   ├── get.test.js
│   │   ├── patch.test.js
│   │   └── put.test.js
│   ├── eslint.config.mjs
│   ├── jest.config.js
│   ├── package-lock.json
│   └── package.json
├── docs
│   ├── ADRs.md                         # Architecture Decision Records
│   └── architecture-diagram.png # Architecture diagram
├── infrastructure
│   ├── backend
│   │   └── global                      # configuration for each environment
│   │       ├── global-infra.tfvars
│   │       ├── global.tf
│   │       └── variables.tf
│   ├── environments                    # configuration for each environment
│   │   └── dev
│   │       ├── dev.tfvars
│   │       ├── dev.tf
│   │       ├── remote-state.tf
│   │       └── variables.tf
│   │   └── test
│   │       ├── test.tfvars
│   │       ├── test.tf
│   │       ├── remote-state.tf
│   │       └── variables.tf
│   │   └── prod
│   │       ├── prod.tfvars
│   │       ├── prod.tf
│   │       ├── remote-state.tf
│   │       └── variables.tf
│   ├── my-modules
│   │   ├── dynamodb
│   │   │   ├── create-table.tf
│   │   │   └── variables.tf
│   │   ├── iam
│   │   │   ├── oidc-provider
│   │   │   │   ├── oidc-provider.tf
│   │   │   └── oidc-role
│   │   │       ├── github-oidc-role.tf
│   │   │       └── variables.tf
│   │   └── lambda
│   │       ├── lambda-with-s3-code-storage.tf
│   │       └── variables.tf
│   ├── resources
│   │   ├── api-gateway
│   │   │   ├── rest-api.tf
│   │   │   └── variables.tf
│   │   ├── iam
│   │   │   ├── api-gateway-role
│   │   │   │   ├── api-gateway-role.tf
│   │   │   │   └── variables.tf
│   │   │   └── lambda-exec-role
│   │   │       ├── lambda-exec-role.tf
│   │   │       └── variables.tf
│   │   ├── lambda
│   │   │   ├── allow-api-gateway-invoke-lambda.tf
│   │   │   └── variables.tf
│   │   └── s3
│   │       ├── create-bucket.tf
│   │       └── variables.tf
│   ├── provider.tf
│   └── variables.tf
├── Architecture.md                       # Architecture documentation
└── README.md

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
