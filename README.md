# Serverless API (Terraform + GitHub Actions + AWS)

This project demonstrates how to build and deploy a **Serverless REST API** on AWS using **Terraform (Infrastructure as Code)** and **GitHub Actions CI/CD pipeline** with **OIDC authentication** resulting in a production level, multi-environment, least privilege cloud architecture.

## Architecture Overview

**High-Level Flow:**

1. **Terraform** → Declaratively defines infrastructure (IaC)
2. **S3 + DynamoDB** → Remote Terraform state locking
3. **GitHub Actions** → CI/CD automation using OIDC (no static AWS keys)
4. **API Gateway** → Public HTTP endpoints
5. **Lambda (Node.js)** → Serverless application logic
6. **DynamoDB** → NoSQL database to persist API data
7. **CloudWatch** → Centralized logging & metrics
8. **Systems Manager (SSM)** → Parameter Store for configuration management
9. **S3** → Lambda source code storage

See [`Architecture.md`](./docs/Architecture.md) for diagram and details.

## Repository Structure

```bash
├── .github/workflows/                          # GitHub Actions pipelines
│   ├── bootstrap-global.yml
│   ├── serverless-api.yml
│   ├── destroy.yml
├── app/
│   ├── handlers/                               # Lambda source code for CRUD functionality
│   ├── tests/                                  # jest unit tests for node.js lambda functions
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

- **AWS Account / IAM User or Role** with permissions for:
  - S3 (Terraform backend + Lambda code)
  - DynamoDB (State locking)
  - IAM (OIDC provider + scoped execution roles)
  - SSM (Parameter storage)
- **Bootstrap Role / Admin User** with **least privilege** for the above resources
- **GitHub Environment Secrets** per environment:
  - `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` (only for bootstrap)
  - `AWS_ACCOUNT_ID` (used in all workflows)
- **Terraform v1.12.2+**

## Setup

**Step 1: Bootstrap Remote Backend**
Run the **bootstrap-global.yml** workflow once (from the global-infra branch).

**This creates:**

- S3 bucket (Terraform remote state)
- DynamoDB table (state locking)
- OIDC provider + IAM roles for dev, test, prod
- SSM Parameters storing backend config
- Lambda source code buckets (per environment)

**Step 2: Deploy Serverless API**

Run the serverless-api.yml workflow for target environment (branch).

**This creates:**

- API Gateway + endpoints
- 4x Lambda functions (CRUD)
- DynamoDB table (API data)
- IAM roles for Lambda & API Gateway (logs)

## CI/CD Environments

This project uses GitHub Actions with environment level isolation and deployment protection for each stage.

| Environment    | Branch         | AWS Context | Authentication                       | Deployment Type      | Protection level               | Purpose                                     |
| -------------- | -------------- | ----------- | ------------------------------------ | -------------------- | ------------------------------ | ------------------------------------------- |
| `global-infra` | `global-infra` | Bootstrap   | Static AWS Admin keys (one time use) | Manuel (on approval) | Protected — reviewers required | Creates global backend (S3, DynamoDB, OIDC) |
| `dev`          | `dev`          | Development | OIDC → IAM Role                      | Automatic (on push)  | Auto deploy                    | Deploys Serverless API (Dev)                |
| `test`         | `test`         | Staging     | OIDC → IAM Role                      | Automatic (on push)  | Auto deploy                    | Deploys Serverless API (Test)               |
| `prod`         | `main`         | Production  | OIDC → IAM Role                      | Manuel (on approval) | Protected — reviewers required | Production release                          |

Each environment has its own **GitHub Environment**, **secrets** and **Terraform remote backend**, ensuring strict separation of state, credentials and deployment permissions.

## CI/CD Workflow Summary

1. Bootstrap (one time) → bootstrap-global.yml
2. Deploy per environment → serverless-api.yml
3. Destroy global/environment → destroy.yml

- On Push:

  - Authenticates via OIDC
  - Runs lint/tests (terraform fmt, validate, Jest)
  - Executes terraform apply (auto-approved for dev/test)

- On Pull Request:

  - Runs terraform plan for pre-deployment review

## Documentation

- Architecture.md → diagrams & design
- ADRs → architectural decisions

## Testing

- Unit tests for Node.js Lambda functions (jest)
- CI validates Terraform formatting, syntax, and plans
- CloudWatch captures application logs and metrics

## Security Best Practices

- No static AWS credentials after bootstrap
- Environment level OIDC roles → least privilege IAM
- Encrypted S3 state + DynamoDB locking
- Backend and config stored securely in SSM
- GitHub Secrets per environment

## Observability

- CloudWatch logs for Lambda + API Gateway
- DynamoDB performance
- Custom CloudWatch Dashboard for visibility

## Cost Optimization

| Service             | Optimization                               | Notes                                                            |
| ------------------- | ------------------------------------------ | ---------------------------------------------------------------- |
| **API Gateway**     | REST API with throttling + stage isolation | More features; could migrate to HTTP API for future cost savings |
| **Lambda**          | Memory tuning + CloudWatch insights        | On demand compute for duration of use                            |
| **DynamoDB**        | On-demand billing for dev / test           | Autoscaling for prod                                             |
| **CloudWatch Logs** | Retention is 7-14 days                     | Prevent log cost buildup                                         |

## Tech Stack

- **Infrastructure**: Terraform (IaC)
- **CI/CD**: GitHub Actions + OIDC Auth
- **Compute**: AWS Lambda (Node.js)
- **Networking**: API Gateway (REST API)
- **Database**: DynamoDB (state locking + app data)
- **Storage**: S3 (state + code)
- **Observability**: CloudWatch
- **Config Management**: SSM Parameter Store

## Future Improvements

- Expand ADRs (cost optimization)
- Integrate Infracost for cost estimation
- Add custom domain + HTTPS (ACM + API Gateway)
- Implement Python Lambda functions
- Add more monitoring dashboards (CloudWatch Dashboards / Grafana)
- Store secrets in AWS Secrets Manager
- Extend CI/CD with Terraform drift detection

## See also

- [Terraform VPC](https://github.com/dtolbertcooke/Terraform-VPC-Infrastructure/)

## Author

Doug Tolbert-Cooke
Cloud & DevOps Engineer
