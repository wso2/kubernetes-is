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
carbon_home=${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}
server_artifact_location=${carbon_home}/repository/deployment/server
sudo /bin/change_ownership.sh
if [[ -d ${HOME}/tmp/server/ ]]; then
   if [[ ! "$(ls -A ${server_artifact_location}/)" ]]; then
      # There are no artifacts under CARBON_HOME/repository/deployment/server/; copy them.
      echo "copying artifacts from ${HOME}/tmp/server/ to ${server_artifact_location}/ .."
      cp -rf ${HOME}/tmp/server/* ${server_artifact_location}/
   fi
   rm -rf ${HOME}/tmp/server/
fi
if [[ -d ${HOME}/tmp/carbon/ ]]; then
   echo "copying custom configurations and artifacts from ${HOME}/tmp/carbon/ to ${carbon_home}/ .."
   cp -rf ${HOME}/tmp/carbon/* ${carbon_home}/
   rm -rf ${HOME}/tmp/carbon/
fi

# Copy ConfigMaps
# Mount any ConfigMap to ${carbon_home}-conf location
if [ -e ${carbon_home}-conf/bin/* ]
 then cp ${carbon_home}-conf/bin/* ${carbon_home}/bin/
fi

if [ -e ${carbon_home}-conf/conf ]
 then cp ${carbon_home}-conf/conf/* ${carbon_home}/repository/conf/
fi

if [ -e ${carbon_home}-conf/conf-axis2 ]
 then cp ${carbon_home}-conf/conf-axis2/* ${carbon_home}/repository/conf/axis2/
fi

if [ -e ${carbon_home}-conf/conf-datasources ]
 then cp ${carbon_home}-conf/conf-datasources/* ${carbon_home}/repository/conf/datasources/
fi

if [ -e ${carbon_home}-conf/conf-identity ]
 then cp ${carbon_home}-conf/conf-identity/* ${carbon_home}/repository/conf/identity/
fi

if [ -e ${carbon_home}-conf/conf-tomcat ]
 then cp ${carbon_home}-conf/conf-tomcat/* ${carbon_home}/repository/conf/tomcat/
fi

if [ -n "$(ls -A ${carbon_home}-lib 2>/dev/null)" ]
 then cp ${carbon_home}-lib/* ${carbon_home}/repository/components/lib/
fi

if [ -n "$(ls -A ${carbon_home}-dropins 2>/dev/null)" ]
 then cp ${carbon_home}-dropins/* ${carbon_home}/repository/components/dropins/
fi

# overwrite localMemberHost element value in axis2.xml with container ip
export local_docker_ip=$(ip route get 1 | awk '{print $NF;exit}')

axi2_xml_location=${carbon_home}/repository/conf/axis2/axis2.xml
if [[ ! -z ${local_docker_ip} ]]; then
   sed -i "s#<parameter\ name=\"localMemberHost\".*#<parameter\ name=\"localMemberHost\">${local_docker_ip}<\/parameter>#" "${axi2_xml_location}"
   if [[ $? == 0 ]]; then
      echo "Successfully updated localMemberHost with ${local_docker_ip}"
   else
      echo "Error occurred while updating localMemberHost with ${local_docker_ip}"
   fi
fi

# Start the carbon server.
${HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/bin/wso2server.sh
