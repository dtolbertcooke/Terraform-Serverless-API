# ADR 4: Compute Choice – AWS Lambda

## Status

Accepted

## Context

We need a scalable, cost effective compute service to run our serverless REST API. The solution should integrate well with our AWS infrastructure, enable event driven architecture for the API, and support CI/CD pipelines.

## Decision

We will use **AWS Lambda** as our serverless compute solution.

### Reasoning:

- Fully managed / Serverless: Server fully managed by AWS.

- Scalability: Automatically scales with demand.

- Cost Efficiency: Pay only for actual compute time used.

- Integration with AWS Services: Seamlessly integrates with API Gateway, DynamoDB, and S3 for our use case.

- Event Driven Architecture: Runs code when events occur like accessing our API endpoints.

## Alternative Consideration

### AWS ECS/Fargate

- Pros: ECS/Fargate are customizable

- Cons: More complex to set up and manage

- Why rejected: More operational overhead and also isn't as cost effective for our use case

### EC2 Instances

- Pros: Full control over the server

- Cons: Requires server management; higher cost

- Why rejected: Higher cost due to EC2 incuring a charge 24/7 regardless of usage.

## Consequences

**Pros**

- No server management required
- On demand autoscaling
- Cost effective for intermittent workloads
- Native AWS integration
- Supports event driven architecture

**Cons**

- Execution time restraints (max 15 minutes)
- Cold start latency for infreqently invoked functions
- Less control over server configuration compared to ECS/EKS/Fargate

## References

- [AWS Compute Services Comparison](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/compute-services.html)
- [Serverless vs Containers: How to Choose](https://docs.aws.amazon.com/modern-apps-strategy-on-aws-how-to-choose/)
