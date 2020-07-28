# setting up release pipeline
register_app_pipeline $REPO_APP_NAME "release" "release.yaml" "${orgAndproj[@]}"

add_pipeline_variable "release" "acrName" "$ACR_NAME" "${orgAndproj[@]}"
add_pipeline_variable "release" "serviceConnection" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"
add_pipeline_variable "release" "serviceName" "$REPO_APP_NAME" "${orgAndproj[@]}"
add_pipeline_variable "release" "manifestRepo" "$MANIFEST_LIVE" "${orgAndproj[@]}"

setup_service_connection $REPO_APP_NAME $DEVOPS_PROJECT $ACR_NAME $DEVOPSORG "release" $SERVICE_CONNECTION_NAME "${orgAndproj[@]}"

# sleeping because the service connection permissions set previously need to propagate first
sleep 5
trigger_pipeline "release" "${orgAndproj[@]}"