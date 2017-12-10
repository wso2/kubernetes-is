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

# NGINX ingress controller
echoBold 'Un-deploying NGINX Ingress Controller ...'
kubectl delete -f is-ingress.yaml
kubectl delete -f nginx-ingress-controller.yaml
kubectl delete -f nginx-default-backend.yaml

# integrator
echoBold 'Un-deploying WSO2 Identity Service ...'
kubectl delete -f is-deployment.yaml
kubectl delete -f is-nfs-volume-claim.yaml
kubectl delete -f is-service.yaml

# databases
echoBold 'Un-deploying WSO2 Identity Databases ...'
kubectl delete -f mysql-deployment.yaml
kubectl delete -f mysql-service.yaml

# configuration maps
echoBold 'Deleting Configuration Maps...'
kubectl delete configmap is-conf
kubectl delete configmap is-conf-datasources
kubectl delete configmap is-conf-identity
kubectl delete configmap is-conf-axis2
kubectl delete configmap is-conf-tomcat

# volumes
echoBold 'Deleting persistent volumes ...'
kubectl delete -f is-nfs-persistent-volume.yaml

echoBold 'Finished'
