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
KUBECTL=`which kubectl`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of WSO2 Identity Server pattern 1 Kubernetes resources\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--ftu | --free-trial-username\t\tYour WSO2 Free Trial username"
    echoBold "--ftp | --free-trial-password\t\tYour WSO2 Free Trial password"
    echoBold "--cap | --cluster-admin-password\tKubernetes cluster admin password\n\n"
}

FT_USERNAME=''
FT_PASSWORD=''
ADMIN_PASSWORD=''

# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`

    case $PARAM in
        -h | --help)
            usage
            exit 1
            ;;
        --ftu | --free-trial-username)
            FT_USERNAME=$VALUE
            ;;
        --ftp | --free-trial-password)
            FT_PASSWORD=$VALUE
            ;;
        --cap | --cluster-admin-password)
            ADMIN_PASSWORD=$VALUE
            ;;
        *)
            echoBold "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

# create a new Kubernetes Namespace
${KUBECTL} create namespace wso2

# create a new service account in 'wso2' Kubernetes Namespace
${KUBECTL} create serviceaccount wso2svc-account -n wso2

# switch the context to new 'wso2' namespace
${KUBECTL} config set-context $(${KUBECTL} config current-context) --namespace=wso2

# create a Kubernetes Secret for passing WSO2 Private Docker Registry credentials
${KUBECTL} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${FT_USERNAME} --docker-password=${FT_PASSWORD} --docker-email=${FT_USERNAME}

# create Kubernetes Role and Role Binding necessary for the Kubernetes API requests made from Kubernetes membership scheme
${KUBECTL} create --username=admin --password=${ADMIN_PASSWORD} -f ../../rbac/rbac.yaml

# create Kubernetes ConfigMaps
echoBold 'Creating ConfigMaps...'
${KUBECTL} create configmap identity-server-conf --from-file=../confs/is/conf/
${KUBECTL} create configmap identity-server-conf-axis2 --from-file=../confs/is/conf/axis2/
${KUBECTL} create configmap identity-server-conf-datasources --from-file=../confs/is/conf/datasources/
${KUBECTL} create configmap identity-server-conf-identity --from-file=../confs/is/conf/identity/
${KUBECTL} create configmap identity-server-conf-event-publishers --from-file=../confs/is/deployment/server/eventpublishers/

${KUBECTL} create configmap is-analytics-1-conf --from-file=../confs/is-analytics-1/conf
${KUBECTL} create configmap is-analytics-1-conf-analytics --from-file=../confs/is-analytics-1/conf/analytics
${KUBECTL} create configmap is-analytics-1-conf-spark-analytics --from-file=../confs/is-analytics-1/conf/analytics/spark
${KUBECTL} create configmap is-analytics-1-conf-axis2 --from-file=../confs/is-analytics-1/conf/axis2
${KUBECTL} create configmap is-analytics-1-conf-datasources --from-file=../confs/is-analytics-1/conf/datasources
${KUBECTL} create configmap is-analytics-1-deployment-portal --from-file=../confs/is-analytics-1/deployment/server/jaggeryapps/portal/configs

${KUBECTL} create configmap is-analytics-2-conf --from-file=../confs/is-analytics-2/conf
${KUBECTL} create configmap is-analytics-2-conf-analytics --from-file=../confs/is-analytics-2/conf/analytics
${KUBECTL} create configmap is-analytics-2-conf-spark-analytics --from-file=../confs/is-analytics-2/conf/analytics/spark
${KUBECTL} create configmap is-analytics-2-conf-axis2 --from-file=../confs/is-analytics-2/conf/axis2
${KUBECTL} create configmap is-analytics-2-conf-datasources --from-file=../confs/is-analytics-2/conf/datasources
${KUBECTL} create configmap is-analytics-2-deployment-portal --from-file=../confs/is-analytics-2/deployment/server/jaggeryapps/portal/configs

${KUBECTL} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Deploying the Kubernetes Services...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-service.yaml
${KUBECTL} create -f ../is/identity-server-service.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-1-service.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-2-service.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-service.yaml
sleep 10s

# MySQL
echoBold 'Deploying WSO2 Identity Server and Identity Server Analytics Databases using MySQL...'
${KUBECTL} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volume and volume claim...'
${KUBECTL} create -f ../is/identity-server-volume-claims.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-volume-claims.yaml
${KUBECTL} create -f ../volumes/persistent-volumes.yaml
sleep 10s

# Identity Server and Analytics
echoBold 'Deploying WSO2 Identity Server and Analytics...'
${KUBECTL} create -f ../is/identity-server-deployment.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-1-deployment.yaml
${KUBECTL} create -f ../is-analytics/identity-server-analytics-2-deployment.yaml
sleep 30s

echoBold 'Deploying Ingresses...'
${KUBECTL} create -f ../ingresses/identity-server-ingress.yaml
${KUBECTL} create -f ../ingresses/identity-server-analytics-ingress.yaml
sleep 30s

echoBold 'Finished'
echo 'To access the WSO2 Identity Server management console, try https://wso2is/carbon in your browser.'
echo 'To access the WSO2 Identity Server Analytics management console, try https://wso2is-analytics/carbon in your browser.'
