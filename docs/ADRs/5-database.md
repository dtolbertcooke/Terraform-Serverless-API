5. Database Choice → Why DynamoDB (NoSQL) vs RDS (SQL).

# ADR 5: Database Choice - DynamoDB

## Status

Accepted

## Context

We need a serverless database solution to store and retrieve application data with high availability, scalability, and minimal operational overhead. The database must integrate easily with AWS, support serverless architecture, and handle intermittent workloads efficiently across multi-tier environments.

## Decision

We will use **Amazon DynamoDB** as our database.

### Reasoning:

- Fully managed / Serverless: Server fully managed by AWS.

- Scalability: Automatically scales throughput and storage based on demand.

- Low latency: miliisecond response time at any scale with on demand or provisioned capacity modes.

- Cost Efficiency: Pay-per-request pricing model ideal for intermittent workloads.

- Integration with AWS Services: Seamlessly integrates with API Gateway, Lambda, and S3 for our use case.

## Alternative Consideration

### Amaon RDS (Relational Database Service)

- Pros: SQL query capabilities; strong ACID guarantees; complex querying capabilities
- Cons: Requires instance management; less scalable for serverless workloads; higher cost for intermittent usage
- Why rejected: More operational overhead and cost compared to DynamoDB for our serverless use case

### Amazon Aurora Serverless

- Pros: Serverless relational database; autoscaling; SQL query capabilities
- Cons: More complex setup; higher cost for intermittent workloads; still requires some management
- Why rejected: Higher cost and complexity compared to DynamoDB for our use case

## Consequences

**Pros**

- No server management required
- On demand autoscaling
- Cost effective for intermittent workloads
- Native AWS integration
- High availability and durability

  **Cons**

- Limited querying capabilities compared to SQL databases
- Requires different data modeling approach (NoSQL)

## References

- [AWS Database Services Comparison](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html)
- [Choosing the Right Database](https://aws.amazon.com/startups/start-building/how-to-choose-a-database/)
