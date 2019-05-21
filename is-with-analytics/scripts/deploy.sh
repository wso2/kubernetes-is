#!/bin/bash

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

set -e

ECHO=`which echo`
KUBERNETES_CLIENT=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

# create a new Kubernetes Namespace
${KUBERNETES_CLIENT} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBERNETES_CLIENT} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBERNETES_CLIENT} config set-context $(${KUBERNETES_CLIENT} config current-context) --namespace=wso2

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBERNETES_CLIENT} create -f ../../rbac/rbac.yaml

# create Kubernetes ConfigMaps
echoBold 'Creating ConfigMaps...'
${KUBERNETES_CLIENT} create configmap identity-server-conf --from-file=../confs/is/conf/
${KUBERNETES_CLIENT} create configmap identity-server-conf-axis2 --from-file=../confs/is/conf/axis2/
${KUBERNETES_CLIENT} create configmap identity-server-conf-datasources --from-file=../confs/is/conf/datasources/
${KUBERNETES_CLIENT} create configmap identity-server-conf-identity --from-file=../confs/is/conf/identity/
${KUBERNETES_CLIENT} create configmap identity-server-conf-event-publishers --from-file=../confs/is/deployment/server/eventpublishers/
${KUBERNETES_CLIENT} create configmap identity-server-conf-tomcat --from-file=../confs/is/conf/tomcat/
${KUBERNETES_CLIENT} create configmap is-analytics-worker-conf --from-file=../confs/is-analytics-worker/conf/worker
${KUBERNETES_CLIENT} create configmap is-analytics-dashboard-conf --from-file=../confs/is-analytics-dashboard/conf/dashboard
${KUBERNETES_CLIENT} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Deploying the Kubernetes Services...'
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-service.yaml
${KUBERNETES_CLIENT} create -f ../is/identity-server-service.yaml
${KUBERNETES_CLIENT} create -f ../is-analytics-worker/identity-server-analytics-worker-service.yaml
${KUBERNETES_CLIENT} create -f ../is-analytics-dashboard/identity-server-analytics-dashboard-service.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volume and volume claim...'
${KUBERNETES_CLIENT} create -f ../is/identity-server-volume-claims.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${KUBERNETES_CLIENT} create -f ../volumes/persistent-volumes.yaml
${KUBERNETES_CLIENT} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
sleep 10s

# MySQL
echoBold 'Deploying WSO2 Identity Server and Identity Server Analytics Databases using MySQL...'
${KUBERNETES_CLIENT} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
sleep 60s

# Identity Server and Analytics
echoBold 'Deploying WSO2 Identity Server and Analytics...'
${KUBERNETES_CLIENT} create -f ../is/identity-server-deployment.yaml
${KUBERNETES_CLIENT} create -f ../is-analytics-worker/identity-server-analytics-worker-deployment.yaml
sleep 30s
${KUBERNETES_CLIENT} create -f ../is-analytics-dashboard/identity-server-analytics-dashboard-deployment.yaml
sleep 30s

echoBold 'Deploying Ingresses...'
${KUBERNETES_CLIENT} create -f ../ingresses/identity-server-ingress.yaml
${KUBERNETES_CLIENT} create -f ../ingresses/identity-server-dashboard-ingress.yaml
sleep 30s

echoBold 'Finished'
echo 'To access the WSO2 Identity Server management console, try https://wso2is/carbon in your browser.'
echo 'To access the WSO2 Identity Server Analytics management console, try https://wso2is-analytics-dashboard/portal in your browser.'
