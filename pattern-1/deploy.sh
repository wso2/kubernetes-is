#!/usr/bin/env bash
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

# methods
function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

set -e

# volumes
echoBold 'Creating persistent volumes ...'
kubectl create -f is-nfs-persistent-volume.yaml

# configuration maps
echoBold 'Creating Configuration Maps ...'
kubectl create configmap is-conf --from-file=conf/is/conf/
kubectl create configmap is-conf-datasources --from-file=conf/is/conf/datasources/
kubectl create configmap is-conf-identity --from-file=conf/is/conf/identity/
kubectl create configmap is-conf-axis2 --from-file=conf/is/conf/axis2/
kubectl create configmap is-conf-tomcat --from-file=conf/is/conf/tomcat/

# mysql
echoBold 'Deploying WSO2 Identity Databases ...'
kubectl create -f mysql-service.yaml
kubectl create -f mysql-deployment.yaml
sleep 10s

# identity server
echoBold 'Deploying WSO2 Identity Service ...'
kubectl create -f is-service.yaml
kubectl create -f is-nfs-volume-claim.yaml
kubectl create -f is-deployment.yaml
sleep 60s

# nginx ingress controller
echoBold 'Deploying NGINX Ingress Controller ...'
kubectl create -f nginx-default-backend.yaml
kubectl create -f nginx-ingress-controller.yaml
kubectl create -f is-ingress.yaml
sleep 20s

echoBold 'Finished'
echo 'To access the console, try https://wso2is-pattern1/carbon in your browser.'
