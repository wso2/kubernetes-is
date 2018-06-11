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
kubectl create configmap identity-server-conf --from-file=../confs/is/conf/
kubectl create configmap identity-server-conf-axis2 --from-file=../confs/is/conf/axis2/
kubectl create configmap identity-server-conf-datasources --from-file=../confs/is/conf/datasources/
kubectl create configmap identity-server-conf-identity --from-file=../confs/is/conf/identity/
kubectl create configmap identity-server-conf-event-publishers --from-file=../confs/is/deployment/server/eventpublishers/

kubectl create configmap is-analytics-1-conf --from-file=../confs/is-analytics-1/conf
kubectl create configmap is-analytics-1-conf-analytics --from-file=../confs/is-analytics-1/conf/analytics
kubectl create configmap is-analytics-1-conf-spark-analytics --from-file=../confs/is-analytics-1/conf/analytics/spark
kubectl create configmap is-analytics-1-conf-axis2 --from-file=../confs/is-analytics-1/conf/axis2
kubectl create configmap is-analytics-1-conf-datasources --from-file=../confs/is-analytics-1/conf/datasources
kubectl create configmap is-analytics-1-deployment-portal --from-file=../confs/is-analytics-1/deployment/server/jaggeryapps/portal/configs

kubectl create configmap is-analytics-2-conf --from-file=../confs/is-analytics-2/conf
kubectl create configmap is-analytics-2-conf-analytics --from-file=../confs/is-analytics-2/conf/analytics
kubectl create configmap is-analytics-2-conf-spark-analytics --from-file=../confs/is-analytics-2/conf/analytics/spark
kubectl create configmap is-analytics-2-conf-axis2 --from-file=../confs/is-analytics-2/conf/axis2
kubectl create configmap is-analytics-2-conf-datasources --from-file=../confs/is-analytics-2/conf/datasources
kubectl create configmap is-analytics-2-deployment-portal --from-file=../confs/is-analytics-2/deployment/server/jaggeryapps/portal/configs

kubectl create configmap mysql-dbscripts --from-file=confs/rdbms/mysql/dbscripts/

# MySQL
echoBold 'Deploying WSO2 Identity Server Databases...'
kubectl create -f rdbms/mysql/mysql-service.yaml
kubectl create -f rdbms/mysql/mysql-deployment.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volume and volume claim...'
kubectl create -f ../is/identity-server-volume-claims.yaml
kubectl create -f ../is-analytics/identity-server-analytics-volume-claims.yaml

kubectl create -f ../volumes/persistent-volumes.yaml

# Identity Server and Analytics
echoBold 'Deploying WSO2 Identity Server and Analytics...'
kubectl create -f ../is/identity-server-service.yaml
kubectl create -f ../is/identity-server-deployment.yaml
kubectl create -f ../is-analytics/identity-server-analytics-1-deployment.yaml
kubectl create -f ../is-analytics/identity-server-analytics-1-service.yaml
kubectl create -f ../is-analytics/identity-server-analytics-2-deployment.yaml
kubectl create -f ../is-analytics/identity-server-analytics-2-service.yaml
kubectl create -f ../is-analytics/identity-server-analytics-service.yaml
sleep 30s

echoBold 'Deploying Ingresses...'
kubectl create -f ../ingresses/identity-server-ingress.yaml
kubectl create -f ../ingresses/identity-server-analytics-ingress.yaml
sleep 30s

echoBold 'Finished'
echo 'To access the WSO2 Identity Server management console, try https://wso2is-scalable-is/carbon in your browser.'
echo 'To access the WSO2 Identity Server Analytics management console, try https://wso2is-analytics/carbon in your browser.'
