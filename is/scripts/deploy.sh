#!/bin/bash

# ------------------------------------------------------------------------
# Copyright 2017 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License
# ------------------------------------------------------------------------

set -e

ECHO=`which echo`
GREP=`which grep`
KUBERNETES_CLIENT=`which kubectl`
SED=`which sed`
TEST=`which test`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

read -p "Do you have a WSO2 Subscription? (Y/N)" -n 1 -r
${ECHO}

if [[ ${REPLY} =~ ^[Yy]$ ]]; then
    read -p "Enter Your WSO2 Username: " WSO2_SUBSCRIPTION_USERNAME
    ${ECHO}
    read -s -p "Enter Your WSO2 Password: " WSO2_SUBSCRIPTION_PASSWORD
    ${ECHO}

    HAS_SUBSCRIPTION=0

    if ! ${GREP} -q "imagePullSecrets" ../identity-server-deployment.yaml; then

        if ! ${SED} -i.bak -e 's|wso2/|docker.wso2.com/|' ../identity-server-deployment.yaml; then
            echoBold "Could not configure to use the Docker image available at WSO2 Private Docker Registry (docker.wso2.com)"
            exit 1
        fi

        if ! ${SED} -i.bak -e '/serviceAccount/a \      imagePullSecrets:' ../identity-server-deployment.yaml; then
            echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create \"imagePullSecrets:\" attribute"
            exit 1
        fi


        if ! ${SED} -i.bak -e '/imagePullSecrets/a \      - name: wso2creds' ../identity-server-deployment.yaml; then
            echoBold "Could not configure Kubernetes Docker image pull secret: Failed to create secret name"
            exit 1
        fi
    fi
elif [[ ${REPLY} =~ ^[Nn]$ || -z "${REPLY}" ]]; then
     HAS_SUBSCRIPTION=1

     if ! ${SED} -i.bak -e '/imagePullSecrets:/d' -e '/- name: wso2creds/d' ../identity-server-deployment.yaml; then
         echoBold "Failed to remove the Kubernetes Docker image pull secret"
         exit 1
     fi

    if ! ${SED} -i.bak -e 's|docker.wso2.com|wso2|' ../identity-server-deployment.yaml; then
        echoBold "Could not configure to use the WSO2 Docker image available at DockerHub"
        exit 1
    fi
else
    echoBold "You have entered an invalid option."
    exit 1
fi

# remove backed up files
${TEST} -f ../*.bak && rm ../*.bak

# create a new Kubernetes Namespace
${KUBERNETES_CLIENT} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBERNETES_CLIENT} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBERNETES_CLIENT} config set-context $(${KUBERNETES_CLIENT} config current-context) --namespace=wso2

if [[ ${HAS_SUBSCRIPTION} -eq 0 ]]; then
    # create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
    ${KUBERNETES_CLIENT} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}
fi

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBERNETES_CLIENT} create -f ../../rbac/rbac.yaml

# create Kubernetes ConfigMaps
echoBold 'Creating Kubernetes ConfigMaps...'
${KUBERNETES_CLIENT} create configmap identity-server-conf --from-file=../confs/
${KUBERNETES_CLIENT} create configmap identity-server-conf-axis2 --from-file=../confs/axis2/
${KUBERNETES_CLIENT} create configmap identity-server-conf-datasources --from-file=../confs/datasources/
${KUBERNETES_CLIENT} create configmap identity-server-conf-identity --from-file=../confs/identity/
${KUBERNETES_CLIENT} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Deploying the Kubernetes Services...'
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-service.yaml
${KUBERNETES_CLIENT} create -f ../identity-server-service.yaml
sleep 10s

# deploying WSO2 product databases using MySQL RDBMS
echoBold 'Deploying WSO2 Identity Server Databases using MySQL...'
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volumes and volume claims...'
${KUBERNETES_CLIENT} create -f ../identity-server-volume-claims.yaml
${KUBERNETES_CLIENT} create -f ../volumes/persistent-volumes.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
sleep 10s

# WSO2 Identity Server
echoBold 'Deploying WSO2 Identity Server...'
${KUBERNETES_CLIENT} create -f ../identity-server-deployment.yaml
sleep 30s

# create Kubernetes Ingress resources
echoBold 'Deploying Kubernetes Ingresses...'
${KUBERNETES_CLIENT} create -f ../ingresses/identity-server-ingress.yaml
sleep 30s

echoBold 'Finished'
echoBold 'To access the WSO2 Identity Server management console, try https://wso2is/carbon in your browser.'
