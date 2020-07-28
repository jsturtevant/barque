#!/usr/bin/env bash

# delete service template if exists and add new service template
function upsert_service_template {
    rm -rf services/$SERVICE_NAME
    mkdir -p services/$SERVICE_NAME

    cp ../$SERVICE_NAME/deployments/* services/$SERVICE_NAME
    cd services/$SERVICE_NAME

    git add .
    git checkout master

    git commit -m "Adding new service templates" || true
    git push origin HEAD:master || true
}

function scaffold_cluster_directory {
    mkdir -p $cluster
    cd ../../
    cp resources/cluster-kustomization.yaml overlays/$RING_NAME/$cluster/tmp-kustomization.yaml

    envsubst < overlays/$RING_NAME/$cluster/tmp-kustomization.yaml > overlays/$RING_NAME/$cluster/kustomization.yaml
    git add overlays/$RING_NAME/$cluster/kustomization.yaml
    cd overlays/$RING_NAME
}

# make the folder, copy the files over as tmp files, use envsubst to sub in the correct values, remove tmp files, and git add
function add_cluster_service_definitions {
    mkdir $SERVICE_NAME
    cd ../../../
    cp resources/image.yaml overlays/$RING_NAME/$cluster/$SERVICE_NAME/tmp-image.yaml
    cp resources/virtual-service.yaml overlays/$RING_NAME/$cluster/$SERVICE_NAME/tmp-virtual-service.yaml
    cp resources/kustomization.yaml overlays/$RING_NAME/$cluster/$SERVICE_NAME/tmp-kustomization.yaml

    cd overlays/$RING_NAME/$cluster/$SERVICE_NAME

    # we need temp files: https://stackoverflow.com/questions/47081507/why-does-rewriting-a-file-with-envsubst-file-file-leave-it-empty
    envsubst < tmp-image.yaml > $SERVICE_NAME-image.yaml
    envsubst < tmp-virtual-service.yaml > $SERVICE_NAME-virtual-service.yaml
    envsubst < tmp-kustomization.yaml > kustomization.yaml

    rm tmp-*
    git add .
    cd ../
}

# removing any existing instances of the service from the clusters
function remove_existing_services {
    for i in $(find . -maxdepth 1 -mindepth 1 -type d); do 
        echo "Targetting this directory"
        echo ${i%%/}; 
        cd ${i%%/}
        echo "Targetting ${i%%} directory and removing ${SERVICE_NAE}"
        rm -rf $SERVICE_NAME
        git rm -r $SERVICE_NAME
        cd ..
    done
}

set -e

# This first export is because I don't know how to define underscores in yaml
export SERVICE_NAME=$SERVICENAME
export RING_NAME=$BUILD_SOURCEBRANCHNAME

ROOT_PATH=$(pwd)
echo "ROOT_PATH: ${ROOT_PATH}"

cd $MANIFESTREPO	
git config user.email "dev@gitops-automation.com"
git config user.name "Gitops Account"

upsert_service_template

# Grabbing the cluster list from cluster-config.json in the root before making folders
cd ../../
if [[ $(jq -r .$RING_NAME cluster-config.json) != "null" ]]; then	
    target_clusters=$(jq -r .$RING_NAME' | map(select(any(.services[]; contains("'$SERVICENAME'")))|.cluster)[]' cluster-config.json)	
else	
    echo "No clusters listed for ${RING_NAME}"	
fi

# Makes the ring folder if doesn't already exist
mkdir -p overlays/$RING_NAME
cd overlays/$RING_NAME

remove_existing_services

git commit -m "Removing existing ${SERVICE_NAME} definitions from ${RING_NAME} clusters" || true

# can get rid of this push, commit twice push once
# git push origin HEAD:master || true

echo "For each cluster, make ${SERVICE_NAME}"
if [[ $target_clusters ]]; then	
    for cluster in $target_clusters; do	
        # if doesn't exist, scaffold and add kustomization.yaml, else append new service to existing kustomization.yaml	
        if [[ ! -d $cluster ]]; then	
            scaffold_cluster_directory	
        else	
            echo -en "\n- ${SERVICENAME}" >> $cluster/kustomization.yaml	
        fi	
        cd $cluster	
        	
        # if we've removed the existing service_repos correctly, this check should be unecessary	
        if [[ ! -d $SERVICENAME ]]; then add_cluster_service_definitions; fi	
        cd ..	
    done	
fi	