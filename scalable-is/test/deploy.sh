#!/usr/bin/env bash

# ------------------------------------------------------------------------
# Copyright 2018 WSO2, Inc. (http://wso2.com)
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

# methods
set -e

function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

# create a new Kubernetes Namespace
kubectl create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
kubectl create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
kubectl config set-context $(kubectl config current-context) --namespace=wso2

kubectl create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=<username> --docker-password=<password> --docker-email=<email>

# create Kubernetes role and role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
kubectl create --username=admin --password=<cluster-admin-password> -f ../../rbac/rbac.yaml

# configuration maps
echoBold 'Creating ConfigMaps...'
kubectl create configmap identity-server-conf --from-file=../confs/repository/conf/
kubectl create configmap identity-server-conf-axis2 --from-file=../confs/repository/conf/axis2/
kubectl create configmap identity-server-conf-datasources --from-file=../confs/repository/conf/datasources/
kubectl create configmap identity-server-conf-identity --from-file=../confs/repository/conf/identity/
kubectl create configmap mysql-dbscripts --from-file=confs/rdbms/mysql/dbscripts/

# MySQL
echoBold 'Deploying WSO2 Identity Server Databases...'
kubectl create -f rdbms/mysql/mysql-service.yaml
kubectl create -f rdbms/mysql/mysql-deployment.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volume and volume claim...'
kubectl create -f ../is/identity-server-volume-claims.yaml
kubectl create -f ../volumes/persistent-volumes.yaml

# Identity Server and Analytics
echoBold 'Deploying WSO2 Identity Server and Analytics...'
kubectl create -f ../is/identity-server-service.yaml
kubectl create -f ../is/identity-server-deployment.yaml
sleep 30s

echoBold 'Deploying Ingresses...'
kubectl create -f ../ingresses/identity-server-ingress.yaml
sleep 30s

echoBold 'Finished'
echo 'To access the WSO2 Identity Server management console, try https://wso2is-scalable-is/carbon in your browser.'
echo 'To access the WSO2 Identity Server Analytics management console, try https://wso2is-analytics/carbon in your browser.'
