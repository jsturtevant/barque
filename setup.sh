#!/bin/bash

set -o errexit
set -o pipefail

source ./functions.sh

#set defaults
DEVOPS_PROJECT=gitops-test
REPO_APP_NAME=app
INITIALIZATION_APP_REPO="https://github.com/Azure-Samples/azure-voting-app-redis.git"
WORKFLOW_STRATEGY=release-flow
SAMPLE=true
SERVICE_CONNECTION_NAME=default-gitops-service-connection
MANIFEST_LIVE=manifest-live
CUSTOM_SETUP_FILE=default

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  --org )
    shift; ORG=$1
    ;;
  -p | --project-name )
    shift; DEVOPS_PROJECT=$1
    ;;
  -r | --repo-app-name )
    shift; REPO_APP_NAME=$1
    ;;
  -acr | --acr-name )
    shift; ACR_NAME=$1
    ;;
  -w | --workflow-strategy )
    shift; WORKFLOW_STRATEGY=$1
    ;;
  -a | --app-repo )
    shift; INITIALIZATION_APP_REPO=$1; SAMPLE=false;
    ;;
  -s | --service-connection-name )
    shift; SERVICE_CONNECTION_NAME=$1
    ;;
  -m | --manifest-repo )
    shift; MANIFEST_LIVE=$1
    ;;
  --custom-pipeline-setup ) 
    shift; CUSTOM_SETUP_FILE=$1
    ;;
esac; shift; done

if [[ "$1" == '--' ]]; then shift; fi

: "${ORG:?Provide <orgname> which will be used to form 'https://dev.azure.com/<orgname>'.  Create an org at https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops }"
: "${DEVOPS_PROJECT:?variable empty or not defined.}"
: "${REPO_APP_NAME:?variable empty or not defined.}"
: "${ACR_NAME:?Please provide an ACR name.}"
: "${WORKFLOW_STRATEGY:?variable empty or not defined.}"
  
DEVOPSORG="https://dev.azure.com/$ORG"

# If we pass in a local filepath, set APP_REPO to absolute filepath, if we pass in git url, keep git url as is
if [[ -d $INITIALIZATION_APP_REPO ]]; then INITIALIZATION_APP_REPO=$(readlink -f $INITIALIZATION_APP_REPO); fi

echo -e "\x1B[32mYou have selected:"
echo -e "\t \x1B[32mOrg: \x1B[36m$DEVOPSORG"
echo -e "\t \x1B[32mProject Name: \x1B[36m$DEVOPS_PROJECT"
echo -e "\t \x1B[32mRepo Name: \x1B[36m$REPO_APP_NAME"
echo -e "\t \x1B[32mWorkflow Strategy: \x1B[36m$WORKFLOW_STRATEGY\x1B[0m (options: release-flow, ring-flow)"
echo -e ""
echo -e "\t \x1B[32mInfra Strategy (use -t to override): \x1B[36mcomming soon\x1B[0m (options: cluster-api-azure, terraform)"
echo -e "\t \x1B[32mRepository for App initialization (use -a to override): \x1B[36m$INITIALIZATION_APP_REPO"
echo -e "\t \x1B[32mArc Enabled: \x1B[36mfalse (comming soon)"
echo -ne "Proceed? [y/n]:\x1B[0m "
read proceed
if [[ "$proceed" != "y" ]]; then
  exit
fi

ensure_dependencies

# 1. Create Repositories
echo "Creating Azure devops Projects and Repositories..."   
if ! az devops project show -p $DEVOPS_PROJECT --org $DEVOPSORG 2>/dev/null; then
  az devops project create --name $DEVOPS_PROJECT --org $DEVOPSORG
fi

orgAndproj=(--org $DEVOPSORG -p $DEVOPS_PROJECT)

# create infra repositories
create_repo infra-live "${orgAndproj[@]}" 

# create gitops repos
create_repo $MANIFEST_LIVE "${orgAndproj[@]}" 
create_repo $REPO_APP_NAME "${orgAndproj[@]}" 

echo "project set up, opening project"
az devops project show --open "${orgAndproj[@]}" 

## 2. TODO Configure the Terffarom infra Strategy

# 3. configure app and pipelines

configure_manifest_repo $MANIFEST_LIVE $DEVOPS_PROJECT $WORKFLOW_STRATEGY $SAMPLE "${orgAndproj[@]}" 
configure_app_repo $REPO_APP_NAME $DEVOPS_PROJECT $INITIALIZATION_APP_REPO $WORKFLOW_STRATEGY $MANIFEST_LIVE "${orgAndproj[@]}"

# using workflow-specific setup strategy

if [[ "$CUSTOM_SETUP_FILE" = default ]]; then 
  source ./workflow-strategies/$WORKFLOW_STRATEGY/pipelines/scripts/setup_pipelines.sh
else 
  source $CUSTOM_SETUP_FILE
fi

set_build_agent_permission $ORG $DEVOPS_PROJECT $MANIFEST_LIVE "${orgAndproj[@]}"
