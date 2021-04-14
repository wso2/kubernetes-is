#!/bin/bash
IS_OPEN_SOURCE=true

if $IS_OPEN_SOURCE; then
    SCRIPT="deployment-scripts/wso2is-ga.sh"
else
    SCRIPT="deployment-scripts/wso2is-latest.sh"
fi

cat > $SCRIPT << "EOF"
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

cat >> $SCRIPT << "EOF"
# bash variables
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""
license_text="LICENSE.txt"

# wso2 image variables
EOF

if $IS_OPEN_SOURCE; then
  echo 'IMG_DEST="wso2"' >> $SCRIPT
  echo 'IMG_TAG="5.11.0"' >> $SCRIPT
else
  echo 'IMG_DEST="docker.wso2.com"' >> $SCRIPT
  echo 'IMG_TAG="5.11.0.0"' >> $SCRIPT
fi

cat >> $SCRIPT << "EOF"


: ${NP_1:=30443};

EOF

if ! $IS_OPEN_SOURCE ; then
  echo "function createLicenseText(){" >> $SCRIPT
  echo 'cat > ${license_text} << "EOF"' >> $SCRIPT
  cat eulatxt >> $SCRIPT
  echo "EOF" >> $SCRIPT; echo "" >> $SCRIPT
  echo "viewLicenseText" >> $SCRIPT; echo "}" >> $SCRIPT
fi

echo "function create_yaml(){" >> $SCRIPT
echo "" >> $SCRIPT
echo 'cat > $k8s_obj_file << "EOF"' >> $SCRIPT
cat ./basic-k8s/namespace.yaml >> $SCRIPT
echo -e "EOF">> $SCRIPT

echo 'cat >> $k8s_obj_file << "EOF"' >> $SCRIPT
cat ./basic-k8s/svcaccount.yaml >> $SCRIPT
if ! $IS_OPEN_SOURCE ; then
  cat ./basic-k8s/secret.yaml >> $SCRIPT
fi
cat ./is-k8s/identity-server-conf.yaml >> $SCRIPT
#cat ./is-k8s/identity-server-conf-entrypoint.yaml >> $SCRIPT
cat ./mysql-k8s/mysql-conf-db.yaml >> $SCRIPT

cat ./mysql-k8s/mysql-service.yaml >> $SCRIPT
cat ./mysql-k8s/mysql-deployment.yaml >> $SCRIPT
cat ./is-k8s/identity-server-service.yaml >> $SCRIPT
cat ./is-k8s/identity-server-deployment.yaml >> $SCRIPT
echo 'EOF' >> $SCRIPT
echo "}" >> $SCRIPT

if $IS_OPEN_SOURCE; then
    cat funcs4opensource >> $SCRIPT
else
    cat funcs >> $SCRIPT
fi

cat >> $SCRIPT << "EOF"
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
