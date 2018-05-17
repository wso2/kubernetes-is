# ------------------------------------------------------------------------
#
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
#
# ------------------------------------------------------------------------

# set to latest Ubuntu LTS
FROM ubuntu:16.04
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"

# set user configurations
ARG USER=wso2user
ARG USER_ID=1000000000
ARG USER_GROUP=wso2
ARG USER_GROUP_ID=1000000000
ARG USER_HOME=/home/${USER}
# set dependant files directory
ARG FILES=./files
# set jdk configurations
ARG JDK=jdk1.8.0*
ARG JAVA_HOME=${USER_HOME}/java
# set wso2 product configurations
ARG WSO2_SERVER=wso2is
ARG WSO2_SERVER_VERSION=5.5.0
ARG WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}
ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}
# set kubernetes dependency bundle information
ARG KUBERNETES_MEMBERSHIP_SCHEME_LIB=kubernetes-membership-scheme-1.0.*.jar
ARG DNS_JAVA_LIB=dnsjava-2.1.*.jar
# install required packages
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl && \
    rm -rf /var/lib/apt/lists/* && \
    echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' \
    >> /etc/bash.bashrc \
    ; echo "\
    Welcome to WSO2 Docker resources.\n\
    The Docker container contains the WSO2 product with its latest updates, which are under the End User License Agreement (EULA) 2.0.\n\
    \n\
    Read more about EULA 2.0 (https://wso2.com/licenses/wso2-update/2.0).\n"\
    > /etc/motd

# create a user group and a user
RUN groupadd --system -g ${USER_GROUP_ID} ${USER_GROUP} && \
    useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP_ID} -u ${USER_ID} ${USER}

# copy the jdk and wso2 product distributions to user's home directory and copy the mysql connector jar to server distribution
WORKDIR ${USER_HOME}
COPY --chown=wso2user:wso2 ${FILES}/${JDK} java
COPY --chown=wso2user:wso2 ${FILES}/${WSO2_SERVER_PACK}/ ${WSO2_SERVER_PACK}/
COPY --chown=wso2user:wso2 ${FILES}/mysql-connector-java-*-bin.jar ${FILES}/${DNS_JAVA_LIB} ${WSO2_SERVER_PACK}/repository/components/lib/
COPY --chown=wso2user:wso2 ${FILES}/${KUBERNETES_MEMBERSHIP_SCHEME_LIB} ${WSO2_SERVER_PACK}/repository/components/dropins/
COPY --chown=wso2user:wso2 ${FILES}/${WSO2_SERVER_PACK}/repository/deployment/server tmp/server
RUN mkdir ${WSO2_SERVER_PACK}-lib && chown wso2user:wso2 ${WSO2_SERVER_PACK}-lib && \
mkdir ${WSO2_SERVER_PACK}-dropins && chown wso2user:wso2 ${WSO2_SERVER_PACK}-dropins && \
mkdir scripts && chown wso2user:wso2 scripts
COPY --chown=wso2user:wso2 init_carbon.sh scripts/

# set the user and work directory
USER ${USER_ID}
WORKDIR ${USER_HOME}

# set environment variables
ENV JAVA_HOME=${JAVA_HOME} \
    PATH=$JAVA_HOME/bin:$PATH \
    WSO2_SERVER_HOME=${WSO2_SERVER_HOME} \
    WORKING_DIRECTORY=${USER_HOME}

# expose ports
EXPOSE 4000 9763 9443

ENTRYPOINT ${WORKING_DIRECTORY}/scripts/init_carbon.sh
