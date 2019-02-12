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
oc=`which oc`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

function usage () {
    echoBold "This script automates the installation of WSO2 Identity Server Openshift resources\n"
    echoBold "Allowed arguments:\n"
    echoBold "-h | --help"
    echoBold "--wu | --wso2-username\t\tYour WSO2 username"
    echoBold "--wp | --wso2-password\t\tYour WSO2 password"
    echoBold "--cap | --cluster-admin-password\tOpenshift cluster admin password\n\n"
}

WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''
ADMIN_PASSWORD=''

# capture named arguments
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`

    case ${PARAM} in
        -h | --help)
            usage
            exit 1
            ;;
        --wu | --wso2-username)
            WSO2_SUBSCRIPTION_USERNAME=${VALUE}
            ;;
        --wp | --wso2-password)
            WSO2_SUBSCRIPTION_PASSWORD=${VALUE}
            ;;
        --cap | --cluster-admin-password)
            ADMIN_PASSWORD=${VALUE}
            ;;
        *)
            echoBold "ERROR: unknown parameter \"${PARAM}\""
            usage
            exit 1
            ;;
    esac
    shift
done

# create a new Openshift Project
${oc}  new-project wso2 --description="wso2" --display-name="wso2"

# swith to the created Project
${oc}  project wso2

# create a new service account in 'wso2' Openshift Project
${oc} create serviceaccount wso2svc-account -n wso2
${oc} adm policy add-scc-to-user privileged -n wso2 -z wso2svc-account

# create a Openshift Secret for passing WSO2 Private Docker Registry credentials
${oc} create secret docker-registry wso2creds --docker-server=docker.wso2.com --docker-username=${WSO2_SUBSCRIPTION_USERNAME} --docker-password=${WSO2_SUBSCRIPTION_PASSWORD} --docker-email=${WSO2_SUBSCRIPTION_USERNAME}

# create Openshift ConfigMaps
echoBold 'Creating Openshift ConfigMaps...'
${oc} create configmap identity-server-conf --from-file=../confs/
${oc} create configmap identity-server-conf-axis2 --from-file=../confs/axis2/
${oc} create configmap identity-server-conf-datasources --from-file=../confs/datasources/
${oc} create configmap identity-server-conf-identity --from-file=../confs/identity/
${oc} create configmap mysql-dbscripts --from-file=../extras/confs/rdbms/mysql/dbscripts/

echoBold 'Deploying the Openshift Services...'
${oc} create -f ../extras/rdbms/mysql/mysql-service.yaml
${oc} create -f ../identity-server-service.yaml
sleep 10s

# deploying WSO2 product databases using MySQL RDBMS
echoBold 'Deploying WSO2 Identity Server Databases using MySQL...'h
${oc} create -f ../extras/rdbms/mysql/mysql-deployment.yaml
sleep 10s

# persistent storage
echoBold 'Creating persistent volumes and volume claims...'
${oc} create -f ../identity-server-volume-claims.yaml
${oc} create -f ../volumes/persistent-volumes.yaml
${oc} create -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${oc} create -f ../extras/rdbms/volumes/persistent-volumes.yaml
sleep 10s

# WSO2 Identity Server
echoBold 'Deploying WSO2 Identity Server...'
${oc} create -f ../identity-server-deployment.yaml
sleep 30s

# create Openshift Ingress resources
echoBold 'Deploying Openshift Routs...'
${oc} create -f ../routes/wso2is-route.yaml

sleep 30s

echoBold 'Finished'
echoBold 'To access the WSO2 Identity Server management console, try https://wso2is/carbon in your browser.'
