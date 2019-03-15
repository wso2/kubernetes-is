#!/bin/bash

ECHO=`which echo`
KUBECTL=`which kubectl`

# methods
function echoBold () {
    echo $'\e[1m'"${1}"$'\e[0m'
}

# delete wso2-is deployment
${KUBECTL} delete -f deployment.yaml

# delete the created Kubernetes Namespace
${KUBECTL} delete namespace wso2

# switch the context to default namespace
${KUBECTL} config set-context $(kubectl config current-context) --namespace=default


echoBold 'Finished'
