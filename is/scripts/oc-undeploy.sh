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

set +e

ECHO=`which echo`
oc=`which oc`

# methods
function echoBold () {
    ${ECHO} $'\e[1m'"${1}"$'\e[0m'
}

# persistent storage
echoBold 'Deleting persistent volume and volume claim...'
${oc} delete -f ../identity-server-volume-claims.yaml
${oc} delete -f ../volumes/persistent-volumes.yaml

# WSO2 Identity Server
echoBold 'Deleting WSO2 Identity Server deployment...'
${oc} delete -f ../identity-server-service.yaml
${oc} delete -f ../identity-server-deployment.yaml

# MySQL
echoBold 'Deleting the MySQL deployment...'
${oc} delete -f ../extras/rdbms/mysql/mysql-service.yaml
${oc} delete -f ../extras/rdbms/mysql/mysql-deployment.yaml
${oc} delete -f ../extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
${oc} delete -f ../extras/rdbms/volumes/persistent-volumes.yaml

# delete the created Kubernetes Namespace
${oc} delete project wso2

# switch the context to default namespace
${oc} project default

echoBold 'Finished'
