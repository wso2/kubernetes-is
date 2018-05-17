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
# The artifacts will be copied to the CARBON_HOME/repository/deployment/server location before the server is started.
server_artifact_location=${WSO2_SERVER_HOME}/repository/deployment/server

if [ -n "$(ls -A ${WORKING_DIRECTORY}/tmp/server 2>/dev/null)" ]; then
   if [ ! "$(ls -A ${server_artifact_location}/)" ]; then
      # There are no artifacts under CARBON_HOME/repository/deployment/server/; copy them.
      echo "copying artifacts from ${WORKING_DIRECTORY}/tmp/server/ to ${server_artifact_location}/ .."
      cp -rf ${WORKING_DIRECTORY}/tmp/server/* ${server_artifact_location}/
   fi
fi

if [ -e ${WORKING_DIRECTORY}/tmp/carbon ]; then
   echo "copying custom configurations and artifacts from ${WORKING_DIRECTORY}/tmp/carbon/ to ${WSO2_SERVER_HOME}/ .."
   cp -rf ${WORKING_DIRECTORY}/tmp/carbon/* ${WSO2_SERVER_HOME}/
fi

# Copy ConfigMaps
# Mount any ConfigMap to ${WSO2_SERVER_HOME}-conf location
if [ -e ${WSO2_SERVER_HOME}-conf/bin/* ]
 then cp ${WSO2_SERVER_HOME}-conf/bin/* ${WSO2_SERVER_HOME}/bin/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf ]
 then cp ${WSO2_SERVER_HOME}-conf/conf/* ${WSO2_SERVER_HOME}/repository/conf/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-axis2 ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-axis2/* ${WSO2_SERVER_HOME}/repository/conf/axis2/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-datasources ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-datasources/* ${WSO2_SERVER_HOME}/repository/conf/datasources/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-identity ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-identity/* ${WSO2_SERVER_HOME}/repository/conf/identity/
fi

if [ -e ${WSO2_SERVER_HOME}-conf/conf-tomcat ]
 then cp ${WSO2_SERVER_HOME}-conf/conf-tomcat/* ${WSO2_SERVER_HOME}/repository/conf/tomcat/
fi

if [ -n "$(ls -A ${WSO2_SERVER_HOME}-lib 2>/dev/null)" ]
 then cp ${WSO2_SERVER_HOME}-lib/* ${WSO2_SERVER_HOME}/repository/components/lib/
fi

if [ -n "$(ls -A ${WSO2_SERVER_HOME}-dropins 2>/dev/null)" ]
 then cp ${WSO2_SERVER_HOME}-dropins/* ${WSO2_SERVER_HOME}/repository/components/dropins/
fi

# capture the Docker container IP from the container's /etc/hosts file
docker_container_ip=$(awk 'END{print $1}' /etc/hosts)

# set the Docker container IP as the `localMemberHost` under axis2.xml clustering configurations (effective only when clustering is enabled)
sed -i "s#<parameter\ name=\"localMemberHost\".*<\/parameter>#<parameter\ name=\"localMemberHost\">${docker_container_ip}<\/parameter>#" ${WSO2_SERVER_HOME}/repository/conf/axis2/axis2.xml

# Start the carbon server.
${WSO2_SERVER_HOME}/bin/wso2server.sh
