# Architecture

## 1. Overview

This project implements a Serverless REST API with CRUD HTTP operations on AWS using Terraform and is automated using CI/CD.

## 2. Infrastructure components

### API Gateway – Public entry point exposing REST API endpoints

- REST API with endpoints for CRUD operations
- Integrated with Lambda functions

### Lambda – Stateless compute power for handling API requests to DynamoDB from endpoints

- Stateless functions for handling API requests
- Written in Node.js (Python next)
- Configured with environment variable for DynamoDB table name

### DynamoDB – NoSQL database for state locking and persistent storage of API data

- NoSQL table with primary key for storing API data
- Auto-scaling enabled for read/write capacity of app DB

### S3 - Static Object storage to contain Terraform state file

- Bucket for storing Terraform state file
- Versioning enabled for production and state file history

### IAM Roles and Policies

- Least privilege roles for Lambda and API Gateway
- OIDC role for GitHub Actions with scoped permissions for Terraform

### Terraform Backend

- S3 bucket for state file storage
- DynamoDB table for state locking

- **CI/CD** – GitHub Actions with OIDC IAM role for secure deployments using least privilege

## 3. Requirements

### Functional

- CRUD (Create, Read, Update, Delete) operations via REST API
- Secure access to resources using IAM roles and policies
- Support multiple environments (dev, test, prod)

### Non-functional

- Security: OIDC-based authentication for CI/CD, least privilege IAM
- Observability: CloudWatch logs and metrics for Lambda/API Gateway
- Scalability: DynamoDB auto-scaling for demand
- Cost Efficiency: Pay-per-request model (Lambda, API Gateway, DynamoDB)
- Reproducibility: Terraform for consistent provisioning

## 4. High-Level Architecture

![Serverless API Architecture](./Serverless_API_Architecture_Diagram.png)

### API flow:

1. Client sends HTTP request to API Gateway using endpoint
2. API Gateway forwards request to Lambda
3. Lambda executes business logic and sends/requests data to/from DynamoDB
4. CI/CD pipeline uses GitHub Actions with Terraform and AWS via OIDC IAM role
5. Terraform state is stored in S3 and lock is handled by DynamoDB

## 5. CI/CD Workflow

- **Trigger**: Push/PR to main/test/prod branch.

- **Steps**:

  1. Lint, format & validate Terraform
  2. Unit tests for lambda code
  3. Fetch backend configurations (state bucket, state locking table, region)
  4. Terraform plan → preview infrastructure changes
  5. Terraform apply → deploy to AWS

- **Security**: GitHub Actions assumes IAM role using OIDC; no long lived credentials

## 6. IaC - Terraform

- Modules:
  - api_gateway/
  - lambda/
  - dynamodb/
  - iam/
  - s3/
- Backend Config:
  - S3 bucket for state file (terraform.tfstate)
  - DynamoDB table for locking

## 7. Security Considerations

- Use IAM roles with least privilege for all services
- OIDC-based authentication for CI/CD to avoid long-lived credentials
- Environment separation using different AWS accounts
- Enable CloudWatch logging for monitoring and auditing
- Regularly review and rotate IAM policies and roles

## 8. Future Improvements

- Add authentication/authorization (Cognito, JWT)
- Implement more detailed monitoring/alerting (CloudWatch Alarms, SNS)
- Integrate with API Gateway custom domain
- Expand ADRs (observability, cost optimization, authentication)
