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

# Product Info
product=wso2is
productVersion=5.4.0

# Container Cluster Manager Info
platform=kubernetes

# MySQL parameters
rdbms=mysql
sqlVersion=5.7

# Image Info
repository=docker.wso2.com/${product}-${rdbms}-${platform}
tag=${sqlVersion}

echo "Creating ${repository}:${tag}..."
docker build -t ${repository}:${tag} .
docker images --filter "dangling=true" -q --no-trunc | xargs docker rmi > /dev/null 2>&1