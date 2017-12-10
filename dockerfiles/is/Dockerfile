# ------------------------------------------------------------------------
#
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
#
# ------------------------------------------------------------------------

FROM ubuntu:16.04
MAINTAINER WSO2 Docker Maintainers "dev@wso2.org"
ENV DEBIAN_FRONTEND noninteractive

# set user information
ARG USER=wso2user
ARG USER_GROUP=wso2
ARG USER_HOME=/home/${USER}

# set local files directory
ARG FILES=./files

# set jdk information
ARG JDK_ARCHIVE=jdk-8u*-linux-x64.tar.gz
ARG JAVA_HOME=${USER_HOME}/java

# set wso2 product information
ARG WSO2_SERVER=wso2is
ARG WSO2_SERVER_VERSION=5.4.0
ARG WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}.zip
ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}

# set jdbc driver information
ARG JDBC_DRIVER=mysql-connector-java-5*-bin.jar

# set kubernetes dependency bundle information
ARG KUBERNETES_MEMBERSHIP_SCHEME_LIB=kubernetes-membership-scheme-1.0.*.jar
ARG DNS_JAVA_LIB=dnsjava-2.1.*.jar

# install required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests unzip telnet iproute2 \
    && rm -rf /var/lib/apt/lists/*

# create user group and user
RUN groupadd --system ${USER_GROUP} && \
    useradd --system --create-home --home-dir ${USER_HOME} --no-log-init -g ${USER_GROUP} ${USER}

# copy jdk, wso2 product distribution, jdbc driver and kubernetes dependency libraries to user's home directory
COPY ${FILES}/${JDK_ARCHIVE} ${FILES}/${WSO2_SERVER_PACK} ${FILES}/${JDBC_DRIVER} \
     ${FILES}/${DNS_JAVA_LIB} ${FILES}/${KUBERNETES_MEMBERSHIP_SCHEME_LIB} ${USER_HOME}/

# install jdk, wso2 server, remove distributions and set folder permissions
RUN unzip -q ${USER_HOME}/${WSO2_SERVER_PACK} -d ${USER_HOME}/ \
    && mkdir -p ${USER_HOME}/tmp \
    && cp -r ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/repository/deployment/server/* ${USER_HOME}/tmp/ \
    && mkdir -p ${JAVA_HOME} \
    && tar -xf ${USER_HOME}/${JDK_ARCHIVE} -C ${JAVA_HOME} --strip-components=1 \
    && cp ${USER_HOME}/${JDBC_DRIVER} ${USER_HOME}/${DNS_JAVA_LIB} ${WSO2_SERVER_HOME}/repository/components/lib/ \
    && cp ${USER_HOME}/${KUBERNETES_MEMBERSHIP_SCHEME_LIB} ${WSO2_SERVER_HOME}/repository/components/dropins/ \
    && rm ${USER_HOME}/${WSO2_SERVER_PACK} \
    && rm ${USER_HOME}/${JDK_ARCHIVE} \
    && rm ${USER_HOME}/${JDBC_DRIVER} \
    && rm ${USER_HOME}/${DNS_JAVA_LIB} \
    && rm ${USER_HOME}/${KUBERNETES_MEMBERSHIP_SCHEME_LIB} \
    && chown -R ${USER}:${USER_GROUP} ${USER_HOME} \
    && chmod -R g=u ${USER_HOME}

# set the user and work directory
USER ${USER_ID}
WORKDIR ${USER_HOME}

# set environment variables
ENV JAVA_HOME=${JAVA_HOME} \
    PATH=$JAVA_HOME/bin:$PATH \
    USER_HOME=${USER_HOME} \
    WSO2_SERVER=${WSO2_SERVER} \
    WSO2_SERVER_VERSION=${WSO2_SERVER_VERSION} \
    WSO2_SERVER_HOME=${WSO2_SERVER_HOME}

# expose ports
EXPOSE 9763 9443

CMD [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf/* ${WSO2_SERVER_HOME}/repository/conf/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-axis2" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-axis2/* ${WSO2_SERVER_HOME}/repository/conf/axis2/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-datasources" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-datasources/* ${WSO2_SERVER_HOME}/repository/conf/datasources/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-email" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-email/* ${WSO2_SERVER_HOME}/repository/conf/email/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-identity" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-identity/* ${WSO2_SERVER_HOME}/repository/conf/identity/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-identity-providers" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-identity-providers/* ${WSO2_SERVER_HOME}/repository/conf/identity/identity-providers/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-service-providers" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-service-providers/* ${WSO2_SERVER_HOME}/repository/conf/identity/service-providers/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-security" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-security/* ${WSO2_SERVER_HOME}/repository/conf/security/; \
    [ -d "${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-tomcat" ] \
        && cp ${USER_HOME}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}-conf/conf-tomcat/* ${WSO2_SERVER_HOME}/repository/conf/tomcat/; \
    [ ! -z "${USER_HOME}/tmp/" ] && cp -rf ${USER_HOME}/tmp/* ${WSO2_SERVER_HOME}/repository/deployment/server/ && rm -rf ${USER_HOME}/tmp; \
    ipaddress=$(ip route get 1 | awk '{print $NF;exit}') && [ ! -z ${ipaddress} ] \
        && sed -i 's/^\([[:space:]]*<parameter name=\"localMemberHost\">\)127\.0\.0\.1\(<\/parameter>.*\)$/\1'${ipaddress}'\2/' ${WSO2_SERVER_HOME}/repository/conf/axis2/axis2.xml; \
    chown -R ${USER}:${USER_GROUP} ${WSO2_SERVER_HOME}/repository/deployment/server && chmod -R g=u ${WSO2_SERVER_HOME}/repository/deployment/server; \
    ${WSO2_SERVER_HOME}/bin/wso2server.sh;
