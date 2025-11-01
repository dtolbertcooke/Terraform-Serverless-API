# Serverless API (Terraform + GitHub Actions + AWS)

This project demonstrates how to build and deploy a **serverless REST API** on AWS using **Infrastructure as Code (Terraform)** and a **CI/CD pipelines (GitHub Actions with OIDC)**.

## Architecture

**High-Level Flow:**

1. **Terraform** → IaC to provision infrastructure
2. **Remote Backend** → Terraform state stored in **S3**, with state locking via **DynamoDB**
3. **CI/CD** → GitHub Actions with **OIDC role assumption** (no static AWS credentials)
4. **API Gateway** → entrypoint for HTTP/S requests
5. **Lambda (Node.js)** → serverless application logic
6. **DynamoDB** → NoSQL database to persist API data

See [`Architecture.md`](./docs/Architecture.md) for diagram and details.

## Repository Structure

```bash
.
├── .github/workflows/                          # GitHub Actions pipelines
│   ├── bootstrap-global.yml
│   ├── serverless-api.yml
│   ├── destroy.yml
├── app/
│   ├── handlers/                               # Lambda source code for CRUD functionality
│   ├── tests/                                  # jest unit tests for node.js lambda functions
│   ├── eslint.config.mjs
│   ├── jest.config.js
│   ├── package-lock.json
│   └── package.json
├── docs/
│   ├── Architecture.md                         # Architecture documentation
│   ├── Serverless_API_Architecture_Diagram.png # Architecture diagram
│   └── ADRs/                                   # Architecture Decision Records
│       ├── 1-iac.md
│       ├── 2-state.md
│       ├── 3-auth.md
│       ├── 4-compute.md
│       ├── 5-database.md
│       ├── 6-cicd.md
│       ├── 7-deploy-strategy.md
│       └── 8-observability.md
├── infrastructure/
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── remote-state.tf
│   ├── variables.tf
│   └── backend/global/                         # global configuration for each environment
│       ├── global-infra.tfvars
│       ├── global.tf
│       ├── outputs.tf
│       └── variables.tf
│   ├── env/                                    # configuration for each environment
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
│   ├── observability/
│       ├── alarms.tf
│       ├── cloudwatch.tf
│       ├── dashboard.tf
│       ├── outputs.tf
│       ├── variables.tf
└── README.md

```

## Prerequisites

- AWS Admin / Account with permissions to create S3 buckets, DynamoDB tables, IAM OIDC provider, IAM policies, IAM roles
- Environment level secrets for bootstrap workflow (Access Key & Secret Access Key)
- Terraform v1.12.2+

## Setup

1. Bootstrap Remote Backend \*_once_

- Admin run bootstrap-global.yml workflow

**This creates:**

- S3 bucket for Terraform state
- 3x S3 bucket for lambda source code (one per environment)
- DynamoDB table for state locking
- 3x IAM roles/1x policy/1x provider for GitHub OIDC

2. Deploy Serverless API

- run serverless-api.yml workflow

**This creates:**

- DynamoDB table for API data
- 2x IAM roles for Lambda / API Gateway
- 4x Lamda functions (CRUD)
- API Gateway REST API

## CI/CD Workflow

1. Manually run bootstrap-global.yml **once** to initialize backend.
2. Build terraform infrastructure for serverless api

- On push to environment:

  - GitHub Actions authenticates to AWS via OIDC
  - Runs tests on lambda code and terraform configuration
  - Auto approve (dev / test branches) → terraform apply
  - On approval (global-infra / prod branches) → terraform apply

- On pull requests:

  - Runs plans for review

## Documentation

- Architecture.md → diagrams & design
- ADRs → key architectural decisions

## Testing

- Unit tests for Node.js Lambda functions (jest).
- Pipeline validates Terraform (terraform fmt, validate, plan).

## Security Best Practices

- No static AWS credentials for main workflow → OIDC used for GitHub Actions.
- Least privilege IAM roles.
- Remote state with locking (S3 + DynamoDB).
- Parameters stored in AWS SSM Parameter Store
- Secrets stored in GitHub Actions enviroment secrets.

## Observability

- CloudWatch logs for Lambda + API Gateway.
- DynamoDB metrics in CloudWatch.
- Dashboard for metrics / logs.

## Future Improvements

- Expand ADRs (cost optimization).
- Add custom domain + HTTPS (ACM + API Gateway).
- Add more monitoring dashboards (CloudWatch Dashboards / Grafana).
- Convert Github environment secrets to AWS secrets management (AWS Secrets Manager).

## See also

- [Terraform VPC](https://github.com/dtolbertcooke/Terraform-VPC-Infrastructure/)

## Author

Doug Tolbert-Cooke
