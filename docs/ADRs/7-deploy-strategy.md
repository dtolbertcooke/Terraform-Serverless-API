# ADR 7: Deployment strategy – Environment Branching (Dev/Test/Prod) with CI/CD Promotion Pipelines

## Status

Accepted

## Context

We need a deployment strategy that allows for clear separation between development, testing, and production environments. The strategy should support continuous integration and continuous deployment (CI/CD) practices, enabling automated deployments while maintaining stability in production.

## Decision

We will use an **Environment Branching Strategy** with dedicated branches for each environment (dev, test, prod) and CI/CD pipelines to promote changes through these environments.

### Reasoning:

- Clear Environment Separation: Each environment has its own branch, reducing the risk of untested code reaching production.

- Controlled Promotion: Changes are promoted through environments via CI/CD pipelines, allowing for automated testing and validation at each stage.

- Stability in Production: The production branch only receives code that has been tested and validated in lower environments.

- Easier Rollbacks: If issues arise in production, we can quickly revert to the last known good state without affecting ongoing development.

- Team Collaboration: Developers can work on features in separate branches and merge them into the appropriate environment branches when ready.

## Alternative Consideration

### Trunk-Based Development with Feature Flags

- Pros: Simplifies branching strategy; encourages frequent integration; reduces merge conflicts

- Cons: Requires feature flag management; potential risk of untested code reaching production

- Why rejected: The team prefers clear environment separation and controlled promotion through CI/CD pipelines for stability

### GitFlow

- Pros: Well defined branching model; supports parallel development and release management

- Cons: More complex branching strategy; can lead to longer release cycles

- Why rejected: The complexity of GitFlow is unnecessary for our current team size and project scope.

## Consequences

**Pros**

- Clear separation of environments
- Controlled promotion through CI/CD pipelines
- Stability in production
- Easier rollbacks
- Improved team collaboration

**Cons**

- More branches to manage
- Potential for merge conflicts between environment branches

## References

- [Git Branching Strategies](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [CI/CD Deployment Strategies](https://docs.aws.amazon.com/whitepapers/latest/practicing-continuous-integration-continuous-delivery/deployment-methods.html)
