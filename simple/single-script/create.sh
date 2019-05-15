#!/bin/bash

DEPLOY_SCRIPT="wso2is-latest.sh"

cat > $DEPLOY_SCRIPT << "EOF"
#!/bin/bash

#-------------------------------------------------------------------------------
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
# limitations under the License.
#--------------------------------------------------------------------------------

set -e
EOF

cat >> $DEPLOY_SCRIPT << "EOF"
# bash variables
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""

# wso2 subscription variables
WUMUsername=''; WUMPassword=''

: ${namespace:="wso2"}
: ${randomPort:=true}; : ${NP_1:=30443};

# testgrid directory
OUTPUT_DIR=$4; INPUT_DIR=$2; TG_PROP="$INPUT_DIR/infrastructure.properties"
EOF

echo "function create_yaml(){" >> $DEPLOY_SCRIPT

echo 'cat > $k8s_obj_file << "EOF"' >> $DEPLOY_SCRIPT; echo 'EOF' >> $DEPLOY_SCRIPT
echo 'if [ "$namespace" == "wso2" ]; then' >> $DEPLOY_SCRIPT

echo 'cat >> $k8s_obj_file << "EOF"' >> $DEPLOY_SCRIPT
cat ../pre-req/wso2is-namespace.yaml >> $DEPLOY_SCRIPT
echo -e "EOF\nfi">> $DEPLOY_SCRIPT

echo 'cat >> $k8s_obj_file << "EOF"' >> $DEPLOY_SCRIPT
cat ../pre-req/wso2is-serviceaccount.yaml >> $DEPLOY_SCRIPT
cat ../pre-req/wso2is-secret.yaml >> $DEPLOY_SCRIPT
cat ../confs/is-confs.yaml >> $DEPLOY_SCRIPT
cat ../confs/is-conf-ds.yaml >> $DEPLOY_SCRIPT
cat ../confs/mysql-conf-db.yaml >> $DEPLOY_SCRIPT
cat ../mysql/wso2is-mysql-service.yaml >> $DEPLOY_SCRIPT
cat ../is/wso2is-service.yaml >> $DEPLOY_SCRIPT
cat ../mysql/wso2is-mysql-deployment.yaml >> $DEPLOY_SCRIPT
cat ../is/wso2is-deployment.yaml >> $DEPLOY_SCRIPT
echo 'EOF' >> $DEPLOY_SCRIPT
echo "}" >> $DEPLOY_SCRIPT

cat functions >> $DEPLOY_SCRIPT

cat >> $DEPLOY_SCRIPT << "EOF"
arg=$1
if [[ -z $arg ]]
then
    echoBold "Expected parameter is missing\n"
    usage
else
  case $arg in
    -d|--deploy)
      deploy
      ;;
    -u|--undeploy)
      undeploy
      ;;
    -h|--help)
      usage
      ;;
    *)
      echoBold "Invalid parameter\n"
      usage
      ;;
  esac
fi
EOF
