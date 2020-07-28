## Notes from figuring out how to give build pool permissions automatically.

- How to assign permission to the build agent pool.  https://docs.microsoft.com/en-us/cli/azure/ext/azure-devops/devops/security/permission?view=azure-cli-latest#ext-azure-devops-az-devops-security-permission-list
- How to get the id? Project Collection Build Service Accounts https://developercommunity.visualstudio.com/content/problem/137489/0000000000aatf401027-genericcontribute-permissions.html
- https://docs.microsoft.com/en-us/azure/devops/cli/security_tokens?view=azure-devops#namespace-name---git-repositories
- https://docs.microsoft.com/en-us/azure/devops/cli/permissions?view=azure-devops
- https://docs.microsoft.com/en-us/azure/devops/pipelines/build/options?view=azure-devops#configure-permissions-to-access-another-repo-in-the-same-project-project-collection

```
az devops security permission namespace list --query "[?namespaceId=='2e9eb7ed-3c0a-47d4-87c1-0ffdd275fd87']"
az devops security group list --scope organization --query "graphGroups[?contains(displayName,'Project Collection Valid Users')]" -o table                                                           
#build agents are added to Security Service Group: 
az devops security group list --scope organization --query "graphGroups[?contains(descriptor,'vssgp.Uy0xLTktMTU1MTM3NDI0NS0xNDMxMTYyNzMwLTQxMjIyOTc5MjQtMjI5NzM1MDgzNC0xNzA0ODY4MzM2LTAtMC0wLTAtNQ')]"
```

## Other options
The other option to adding permissions to the build service agent is to prompt user for access key to use az pr creation used in the release piplines: 
 - service principal log in via az login isn't supported, in which case a PAT token is required.
 - https://docs.microsoft.com/en-us/azure/devops/cli/log-in-via-pat?view=azure-devops&tabs=windows
 - https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&viewFallbackFrom=vsts&tabs=preview-page#create-personal-access-tokens-to-authenticate-access
 - could auto open them to https://dev.azure.com/jstur/_usersSettings/tokens