# Barque Ring-flow 

Ring-flow is a workflow strategy in barque that implements rings via Istio into your manifest repo. We are using kustomize to manage kubernetes templates.

## Prerequisites 

Dependencies:

- jq
- azure cli
- git

Infrastructure requirements:

- an existing ACR
- an existing Azure Devops org

Your service must have a folder that contains your base deployment templates:

```
$SERVICE_NAME <---- root
├── deployments
│   ├── $SERVICE_NAME-virtual-services.yaml
│   ├── $SERVICE_NAME.yaml
│   └── kustomization.yaml
```

The $SERVICE_NAME.yaml is the kubernetes definition for your service. The $SERVICE_NAME-virtual-services.yaml defines the ingressgateway for your service. kustomization.yaml is a resource file. You'll need to commit these files because we git pull.

Currently, you must also add a cluster-config.json to the manifest-repo in barque:
```
gitops <---- barque root
├── workflow-strategies/ring-flow/manifest
│   └── cluster-config.json
```

cluster-config.json:
```
{
    "dev":[
      {
        "cluster": "dev-cluster1",
        "services": [
          "a",
          "b"
        ]
      }
    ],
    "prod":[
      {
        "cluster": "prod-cluster1",
        "services": [
          "a",
          "c"
        ]
      },
      {
        "cluster": "prod-cluster2",
        "services": [
          "b"
        ]
      }
    ]
  }  
  ```

This is the format you must follow. The way you read this is:

- there are two "rings": dev and prod
- dev has a single cluster named "dev-cluster1" that uses services a and b
- prod has two clusters named "prod-cluster1" and "prod-cluster2"
    - "prod-cluster1" uses services a and c
    - "prod-cluster2" only uses service b

In the "prod" ring, every cluster's services will be on their "prod" versions. In the "dev" ring, every cluster will use the "dev" version of services. 

## Usage

```
./setup.sh --org $ORG_NAME -p $PROJECT_NAME -r $REPO_NAME -acr $ACR_NAME -w ring-flow -a $REPO_PATH
```
Flags:

- --org: Your Azure Devops org, must exist already
- -p: Your Azure Devops project, does not need to be existing
- -r: The name of the repo you want your service to live in
- -acr: Your ACR name, ACR must exist already
- -w: Your workflow strategy, use "ring-flow"
- -a: Path to your service code, must be a git repo and can be local or remote

