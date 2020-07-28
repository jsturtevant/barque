# Need to update this a little for release-flow, currently set to ring flow


# setting up release pipeline
register_app_pipeline $REPO_APP_NAME "release" "release.yaml" "${orgAndproj[@]}"

add_pipeline_variable "release" "manifest-repo" "$DEVOPS_PROJECT/$MANIFEST_LIVE" "${orgAndproj[@]}"
add_pipeline_variable "release" "acrName" "$ACR_NAME" "${orgAndproj[@]}"
add_pipeline_variable "release" "serviceConnection" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"

setup_service_connection $REPO_APP_NAME $DEVOPS_PROJECT $ACR_NAME $DEVOPSORG "release" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"

# sleeping because the service connection permissions set previously need to propagate first
sleep 5
trigger_pipeline "release" "${orgAndproj[@]}"

# setting up pr-build pipeline
register_app_pipeline $REPO_APP_NAME "pr-build"  "pr.yaml" "${orgAndproj[@]}"

add_pipeline_variable "pr-build" "manifest-repo" "$DEVOPS_PROJECT/$MANIFEST_LIVE" "${orgAndproj[@]}"
add_pipeline_variable "pr-build" "acrName" "$ACR_NAME" "${orgAndproj[@]}"
add_pipeline_variable "pr-build" "serviceConnection" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"

apply_pr_policy $REPO_APP_NAME $DEVOPS_PROJECT "pr-build" "${orgAndproj[@]}"
setup_service_connection $REPO_APP_NAME $DEVOPS_PROJECT $ACR_NAME $DEVOPSORG "pr-build" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"

trigger_pipeline "pr-build" "${orgAndproj[@]}"
