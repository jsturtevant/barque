# Barque Release-flow 

Release-flow is a workflow strategy in barque that implements [git release flow strategy](https://docs.microsoft.com/en-us/azure/devops/learn/devops-at-microsoft/release-flow).

Example Workflow:

1. Dev checks in code
2. Security checks, linting, build push to ACR (automated)
3. Update Dev manifests with image id from ACR - Deployed automatically to dev via flex pull (automated)
4. Update Staging manifests with image id from ACR - Deployed automatically to staging via flux pull (automated)
5. Open PR against production manifests with image id (automated)
6. Operator merges PR when ready to move to production
7. Prod cluster pulls updates to cluster