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
# bash variables
k8s_obj_file="deployment.yaml"; NODE_IP=''; str_sec=""
IMG_DEST="wso2"

# wso2 subscription variables
WUMUsername=''; WUMPassword=''

: ${namespace:="wso2"}
: ${randomPort:="False"}; : ${NP_1:=30443};

# testgrid directory
OUTPUT_DIR=$4; INPUT_DIR=$2; TG_PROP="$INPUT_DIR/infrastructure.properties"
function create_yaml(){
cat > $k8s_obj_file << "EOF"
EOF
if [ "$namespace" == "wso2" ]; then
cat >> $k8s_obj_file << "EOF"
apiVersion: v1
kind: Namespace
metadata:
  name: wso2
spec:
  finalizers:
    - kubernetes
---
EOF
fi
cat >> $k8s_obj_file << "EOF"

apiVersion: v1
kind: ServiceAccount
metadata:
  name: wso2svc-account
  namespace: "$ns.k8s&wso2.is"
secrets:
  - name: wso2svc-account-token-t7s49
---

apiVersion: v1
data:
  carbon.xml: |
    <?xml version="1.0" encoding="ISO-8859-1"?>
    <Server xmlns="http://wso2.org/projects/carbon/carbon.xml">
        <Name>WSO2 Identity Server</Name>
        <ServerKey>IS</ServerKey>
        <Version>5.7.0</Version>
        <HostName>wso2is</HostName>
        <MgtHostName>wso2is</MgtHostName>
        <ServerURL>local:/${carbon.context}/services/</ServerURL>
        <ServerRoles>
            <Role>IdentityServer</Role>
        </ServerRoles>
        <Package>org.wso2.carbon</Package>
        <WebContextRoot>/</WebContextRoot>
        <ItemsPerPage>15</ItemsPerPage>
        <Ports>
            <Offset>0</Offset>
            <JMX>
                <RMIRegistryPort>9999</RMIRegistryPort>
                <RMIServerPort>11111</RMIServerPort>
            </JMX>
            <EmbeddedLDAP>
                <LDAPServerPort>10389</LDAPServerPort>
                <KDCServerPort>8000</KDCServerPort>
            </EmbeddedLDAP>
        <ThriftEntitlementReceivePort>10500</ThriftEntitlementReceivePort>
        </Ports>
        <JNDI>
            <DefaultInitialContextFactory>org.wso2.carbon.tomcat.jndi.CarbonJavaURLContextFactory</DefaultInitialContextFactory>
            <Restrictions>
                <AllTenants>
                    <UrlContexts>
                        <UrlContext>
                            <Scheme>java</Scheme>
                        </UrlContext>
                    </UrlContexts>
                </AllTenants>
            </Restrictions>
        </JNDI>
        <IsCloudDeployment>false</IsCloudDeployment>
        <EnableMetering>false</EnableMetering>
        <MaxThreadExecutionTime>600</MaxThreadExecutionTime>
        <GhostDeployment>
            <Enabled>false</Enabled>
        </GhostDeployment>
        <Tenant>
            <LoadingPolicy>
                <LazyLoading>
                    <IdleTime>30</IdleTime>
                </LazyLoading>
            </LoadingPolicy>
        </Tenant>
        <Cache>
            <DefaultCacheTimeout>15</DefaultCacheTimeout>
            <ForceLocalCache>false</ForceLocalCache>
        </Cache>
        <Axis2Config>
            <RepositoryLocation>${carbon.home}/repository/deployment/server/</RepositoryLocation>
            <DeploymentUpdateInterval>15</DeploymentUpdateInterval>
            <ConfigurationFile>${carbon.home}/repository/conf/axis2/axis2.xml</ConfigurationFile>
            <ServiceGroupContextIdleTime>30000</ServiceGroupContextIdleTime>
            <clientAxis2XmlLocation>${carbon.home}/repository/conf/axis2/axis2_client.xml</clientAxis2XmlLocation>
            <HideAdminServiceWSDLs>true</HideAdminServiceWSDLs>
       </Axis2Config>
        <ServiceUserRoles>
            <Role>
                <Name>admin</Name>
                <Description>Default Administrator Role</Description>
            </Role>
            <Role>
                <Name>user</Name>
                <Description>Default User Role</Description>
            </Role>
        </ServiceUserRoles>
        <CryptoService>
            <Enabled>true</Enabled>
            <InternalCryptoProviderClassName>org.wso2.carbon.crypto.provider.KeyStoreBasedInternalCryptoProvider</InternalCryptoProviderClassName>
            <ExternalCryptoProviderClassName>org.wso2.carbon.core.encryption.KeyStoreBasedExternalCryptoProvider</ExternalCryptoProviderClassName>
            <KeyResolvers>
                <KeyResolver className="org.wso2.carbon.crypto.defaultProvider.resolver.ContextIndependentKeyResolver" priority="-1"/>
            </KeyResolvers>
        </CryptoService>
        <Security>
            <KeyStore>
                <Location>${carbon.home}/repository/resources/security/wso2carbon.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
                <KeyAlias>wso2carbon</KeyAlias>
                <KeyPassword>wso2carbon</KeyPassword>
            </KeyStore>
            <InternalKeyStore>
                <Location>${carbon.home}/repository/resources/security/wso2carbon.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
                <KeyAlias>wso2carbon</KeyAlias>
                <KeyPassword>wso2carbon</KeyPassword>
            </InternalKeyStore>
            <TrustStore>
                <Location>${carbon.home}/repository/resources/security/client-truststore.jks</Location>
                <Type>JKS</Type>
                <Password>wso2carbon</Password>
            </TrustStore>
            <NetworkAuthenticatorConfig>
            </NetworkAuthenticatorConfig>
            <TomcatRealm>UserManager</TomcatRealm>
        <DisableTokenStore>false</DisableTokenStore>
     <STSCallBackHandlerName>org.wso2.carbon.identity.provider.AttributeCallbackHandler</STSCallBackHandlerName>
        <TokenStoreClassName>org.wso2.carbon.identity.sts.store.DBTokenStore</TokenStoreClassName>
            <XSSPreventionConfig>
                <Enabled>true</Enabled>
                <Rule>allow</Rule>
                <Patterns>
                </Patterns>
            </XSSPreventionConfig>
        </Security>
    <HideMenuItemIds>
    <HideMenuItemId>claim_mgt_menu</HideMenuItemId>
    <HideMenuItemId>identity_mgt_emailtemplate_menu</HideMenuItemId>
    <HideMenuItemId>identity_security_questions_menu</HideMenuItemId>
    </HideMenuItemIds>
        <WorkDirectory>${carbon.home}/tmp/work</WorkDirectory>
        <HouseKeeping>
            <AutoStart>true</AutoStart>
            <Interval>10</Interval>
            <MaxTempFileLifetime>30</MaxTempFileLifetime>
        </HouseKeeping>
        <FileUploadConfig>
            <TotalFileSizeLimit>100</TotalFileSizeLimit>
            <Mapping>
                <Actions>
                    <Action>keystore</Action>
                    <Action>certificate</Action>
                    <Action>*</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.AnyFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>jarZip</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.JarZipUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>dbs</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.DBSFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>tools</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsFileUploadExecutor</Class>
            </Mapping>
            <Mapping>
                <Actions>
                    <Action>toolsAny</Action>
                </Actions>
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsAnyFileUploadExecutor</Class>
            </Mapping>
        </FileUploadConfig>
        <HttpGetRequestProcessors>
            <Processor>
                <Item>info</Item>
                <Class>org.wso2.carbon.core.transports.util.InfoProcessor</Class>
            </Processor>
            <Processor>
                <Item>wsdl</Item>
                <Class>org.wso2.carbon.core.transports.util.Wsdl11Processor</Class>
            </Processor>
            <Processor>
                <Item>wsdl2</Item>
                <Class>org.wso2.carbon.core.transports.util.Wsdl20Processor</Class>
            </Processor>
            <Processor>
                <Item>xsd</Item>
                <Class>org.wso2.carbon.core.transports.util.XsdProcessor</Class>
            </Processor>
        </HttpGetRequestProcessors>
        <DeploymentSynchronizer>
            <Enabled>false</Enabled>
            <AutoCommit>false</AutoCommit>
            <AutoCheckout>true</AutoCheckout>
            <RepositoryType>svn</RepositoryType>
            <SvnUrl>http://svnrepo.example.com/repos/</SvnUrl>
            <SvnUser>username</SvnUser>
            <SvnPassword>password</SvnPassword>
            <SvnUrlAppendTenantId>true</SvnUrlAppendTenantId>
        </DeploymentSynchronizer>
        <ServerInitializers>
        </ServerInitializers>
        <RequireCarbonServlet>${require.carbon.servlet}</RequireCarbonServlet>
        <StatisticsReporterDisabled>true</StatisticsReporterDisabled>
        <FeatureRepository>
            <RepositoryName>default repository</RepositoryName>
            <RepositoryURL>http://product-dist.wso2.com/p2/carbon/releases/wilkes/</RepositoryURL>
        </FeatureRepository>
       <APIManagement>
        <Enabled>true</Enabled>
        <LoadAPIContextsInServerStartup>true</LoadAPIContextsInServerStartup>
       </APIManagement>
    </Server>
kind: ConfigMap
metadata:
  name: identity-server-conf
  namespace: "$ns.k8s&wso2.is"

---

apiVersion: v1
data:
  bps-datasources.xml: |
    <datasources-configuration xmlns:svns="http://org.wso2.securevault/configuration">
       <providers>
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>
        </providers>
      <datasources>
            <datasource>
                <name>BPS_DS</name>
                <description></description>
                <jndiConfig>
                    <name>bpsds</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:./repository/database/WSO2IS_BPS_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>100</maxActive>
                        <maxWait>10000</maxWait>
                        <maxIdle>20</maxIdle>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <useDataSourceFactory>false</useDataSourceFactory>
                        <defaultAutoCommit>true</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
        </datasources>
    </datasources-configuration>
  master-datasources.xml: |
    <datasources-configuration xmlns:svns="http://org.wso2.securevault/configuration">
        <providers>
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>
        </providers>
        <datasources>
            <datasource>
                <name>WSO2_CARBON_DB</name>
                <description>The datasource used for registry and user manager</description>
                <jndiConfig>
                    <name>jdbc/WSO2CarbonDB</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:./repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>false</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2_USER_DB</name>
                <description>The data source used for user management and user store</description>
                <jndiConfig>
                    <name>jdbc/WSO2UserDS</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:mysql://wso2is-rdbms-service:3306/WSO2IS_USER_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>
                        <maxActive>80</maxActive>
                        <maxWait>60000</maxWait>
                        <minIdle>5</minIdle>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>false</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2_CONFIG_REG_DB</name>
                <description>The data source used for config registry</description>
                <jndiConfig>
                    <name>jdbc/WSO2ConfigDS</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:./repository/database/WSO2IS_REG_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>50</maxActive>
                        <maxWait>60000</maxWait>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2_IDENTITY_DB</name>
                <description>The data source used for identity</description>
                <jndiConfig>
                    <name>jdbc/WSO2IdentityDS</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:mysql://wso2is-rdbms-service:3306/WSO2IS_IDENTITY_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>
                        <maxActive>80</maxActive>
                        <maxWait>60000</maxWait>
                        <minIdle>5</minIdle>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>false</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
            <datasource>
                <name>WSO2_CONSENT_DB</name>
                <description>The data source used for consent management</description>
                <jndiConfig>
                    <name>jdbc/WSO2ConsentDS</name>
                </jndiConfig>
                <definition type="RDBMS">
                    <configuration>
                        <url>jdbc:h2:./repository/database/WSO2IS_CONSENT_DB?autoReconnect=true&amp;useSSL=false</url>
                        <username>wso2carbon</username>
                        <password>wso2carbon</password>
                        <driverClassName>org.h2.Driver</driverClassName>
                        <maxActive>80</maxActive>
                        <maxWait>60000</maxWait>
                        <minIdle>5</minIdle>
                        <testOnBorrow>true</testOnBorrow>
                        <validationQuery>SELECT 1</validationQuery>
                        <validationInterval>30000</validationInterval>
                        <defaultAutoCommit>false</defaultAutoCommit>
                    </configuration>
                </definition>
            </datasource>
       </datasources>
    </datasources-configuration>
kind: ConfigMap
metadata:
  name: identity-server-conf-datasources
  namespace: "$ns.k8s&wso2.is"
---

apiVersion: v1
data:
  init.sql: |
    DROP DATABASE IF EXISTS WSO2IS_USER_DB;
    DROP DATABASE IF EXISTS WSO2IS_IDENTITY_DB;
    DROP DATABASE IF EXISTS IS_ANALYTICS_DB;
    CREATE DATABASE WSO2IS_USER_DB;
    CREATE DATABASE WSO2IS_IDENTITY_DB;
    CREATE DATABASE IS_ANALYTICS_DB;
    CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON WSO2IS_USER_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON WSO2IS_IDENTITY_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    GRANT ALL ON IS_ANALYTICS_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
    USE WSO2IS_USER_DB;
    CREATE TABLE UM_TENANT (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255) NOT NULL,
                UM_EMAIL VARCHAR(255),
                UM_ACTIVE BOOLEAN DEFAULT FALSE,
                UM_CREATED_DATE TIMESTAMP NOT NULL,
                UM_USER_CONFIG LONGBLOB,
                PRIMARY KEY (UM_ID),
                UNIQUE(UM_DOMAIN_NAME)
    )ENGINE INNODB;
    CREATE TABLE UM_DOMAIN(
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME
                        ON UM_TENANT (UM_DOMAIN_NAME);
    CREATE TABLE UM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE(
        UM_ID INTEGER  NOT NULL AUTO_INCREMENT,
        UM_MODULE_NAME VARCHAR(100),
        UNIQUE(UM_MODULE_NAME),
        PRIMARY KEY(UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE_ACTIONS(
        UM_ACTION VARCHAR(255) NOT NULL,
        UM_MODULE_ID INTEGER NOT NULL,
        PRIMARY KEY(UM_ACTION, UM_MODULE_ID),
        FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,
                 UM_ACTION VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_MODULE_ID INTEGER DEFAULT 0,
                       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);
    CREATE TABLE UM_ROLE_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
             UM_DOMAIN_ID INTEGER,
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),
             FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
             FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_ID INTEGER NOT NULL,
                 UM_USER_ID INTEGER NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SHARED_USER_ROLE(
        UM_ROLE_ID INTEGER NOT NULL,
        UM_USER_ID INTEGER NOT NULL,
        UM_USER_TENANT_ID INTEGER NOT NULL,
        UM_ROLE_TENANT_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_ACCOUNT_MAPPING(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_USER_NAME VARCHAR(255) NOT NULL,
        UM_TENANT_ID INTEGER NOT NULL,
        UM_USER_STORE_DOMAIN VARCHAR(100),
        UM_ACC_LINK_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
        FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,
        PRIMARY KEY (UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_ATTRIBUTE (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ATTR_NAME VARCHAR(255) NOT NULL,
                UM_ATTR_VALUE VARCHAR(1024),
                UM_PROFILE_ID VARCHAR(255),
                UM_USER_ID INTEGER,
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);
    CREATE TABLE UM_DIALECT(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_URI VARCHAR(255) NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_CLAIM(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_CLAIM_URI VARCHAR(255) NOT NULL,
                UM_DISPLAY_TAG VARCHAR(255),
                UM_DESCRIPTION VARCHAR(255),
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),
                UM_MAPPED_ATTRIBUTE VARCHAR(255),
                UM_REG_EX VARCHAR(255),
                UM_SUPPORTED SMALLINT,
                UM_REQUIRED SMALLINT,
                UM_DISPLAY_ORDER INTEGER,
            UM_CHECKED_ATTRIBUTE SMALLINT,
                UM_READ_ONLY SMALLINT,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_PROFILE_CONFIG(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_PROFILE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_PROFILE_ID INTEGER,
        UM_CLAIM_ID INTEGER,
        UM_BEHAVIOUR SMALLINT,
        UM_TENANT_ID INTEGER DEFAULT 0,
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),
        PRIMARY KEY(UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
            UM_DOMAIN_ID INTEGER,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
            FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);
    CREATE TABLE UM_SYSTEM_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_REMEMBER_ME(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255) NOT NULL,
                UM_COOKIE_VALUE VARCHAR(1024),
                UM_CREATED_TIME TIMESTAMP,
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    USE WSO2IS_IDENTITY_DB;
    CREATE TABLE UM_TENANT (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255) NOT NULL,
                UM_EMAIL VARCHAR(255),
                UM_ACTIVE BOOLEAN DEFAULT FALSE,
                UM_CREATED_DATE TIMESTAMP NOT NULL,
                UM_USER_CONFIG LONGBLOB,
                PRIMARY KEY (UM_ID),
                UNIQUE(UM_DOMAIN_NAME)
    )ENGINE INNODB;
    CREATE TABLE UM_DOMAIN(
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DOMAIN_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME
                        ON UM_TENANT (UM_DOMAIN_NAME);
    CREATE TABLE UM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_USER (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,
                 UM_SALT_VALUE VARCHAR(31),
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE(
        UM_ID INTEGER  NOT NULL AUTO_INCREMENT,
        UM_MODULE_NAME VARCHAR(100),
        UNIQUE(UM_MODULE_NAME),
        PRIMARY KEY(UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_MODULE_ACTIONS(
        UM_ACTION VARCHAR(255) NOT NULL,
        UM_MODULE_ID INTEGER NOT NULL,
        PRIMARY KEY(UM_ACTION, UM_MODULE_ID),
        FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,
                 UM_ACTION VARCHAR(255) NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
            UM_MODULE_ID INTEGER DEFAULT 0,
                       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);
    CREATE TABLE UM_ROLE_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
             UM_DOMAIN_ID INTEGER,
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),
             FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
             FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_PERMISSION (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_PERMISSION_ID INTEGER NOT NULL,
                 UM_USER_NAME VARCHAR(255) NOT NULL,
                 UM_IS_ALLOWED SMALLINT NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_ROLE (
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                 UM_ROLE_ID INTEGER NOT NULL,
                 UM_USER_ID INTEGER NOT NULL,
                 UM_TENANT_ID INTEGER DEFAULT 0,
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SHARED_USER_ROLE(
        UM_ROLE_ID INTEGER NOT NULL,
        UM_USER_ID INTEGER NOT NULL,
        UM_USER_TENANT_ID INTEGER NOT NULL,
        UM_ROLE_TENANT_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE UM_ACCOUNT_MAPPING(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_USER_NAME VARCHAR(255) NOT NULL,
        UM_TENANT_ID INTEGER NOT NULL,
        UM_USER_STORE_DOMAIN VARCHAR(100),
        UM_ACC_LINK_ID INTEGER NOT NULL,
        UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),
        FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,
        PRIMARY KEY (UM_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_USER_ATTRIBUTE (
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ATTR_NAME VARCHAR(255) NOT NULL,
                UM_ATTR_VALUE VARCHAR(1024),
                UM_PROFILE_ID VARCHAR(255),
                UM_USER_ID INTEGER,
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);
    CREATE TABLE UM_DIALECT(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_URI VARCHAR(255) NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_CLAIM(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_CLAIM_URI VARCHAR(255) NOT NULL,
                UM_DISPLAY_TAG VARCHAR(255),
                UM_DESCRIPTION VARCHAR(255),
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),
                UM_MAPPED_ATTRIBUTE VARCHAR(255),
                UM_REG_EX VARCHAR(255),
                UM_SUPPORTED SMALLINT,
                UM_REQUIRED SMALLINT,
                UM_DISPLAY_ORDER INTEGER,
            UM_CHECKED_ATTRIBUTE SMALLINT,
                UM_READ_ONLY SMALLINT,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_PROFILE_CONFIG(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_DIALECT_ID INTEGER NOT NULL,
                UM_PROFILE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,
        UM_PROFILE_ID INTEGER,
        UM_CLAIM_ID INTEGER,
        UM_BEHAVIOUR SMALLINT,
        UM_TENANT_ID INTEGER DEFAULT 0,
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),
        PRIMARY KEY(UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
            UM_DOMAIN_ID INTEGER,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,
            FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_SYSTEM_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_ROLE_NAME VARCHAR(255),
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);
    CREATE TABLE UM_SYSTEM_USER_ROLE(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255),
                UM_ROLE_ID INTEGER NOT NULL,
                UM_TENANT_ID INTEGER DEFAULT 0,
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE UM_HYBRID_REMEMBER_ME(
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,
                UM_USER_NAME VARCHAR(255) NOT NULL,
                UM_COOKIE_VALUE VARCHAR(1024),
                UM_CREATED_TIME TIMESTAMP,
                UM_TENANT_ID INTEGER DEFAULT 0,
                PRIMARY KEY (UM_ID, UM_TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (
                PRODUCT_NAME VARCHAR(20),
                PRIMARY KEY (PRODUCT_NAME)
    )ENGINE INNODB;
    INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');
    CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                CONSUMER_KEY VARCHAR(255),
                CONSUMER_SECRET VARCHAR(2048),
                USERNAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT 0,
                USER_DOMAIN VARCHAR(50),
                APP_NAME VARCHAR(255),
                OAUTH_VERSION VARCHAR(128),
                CALLBACK_URL VARCHAR(1024),
                GRANT_TYPES VARCHAR (1024),
                PKCE_MANDATORY CHAR(1) DEFAULT '0',
                PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',
                APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',
                USER_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                APP_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                REFRESH_TOKEN_EXPIRE_TIME BIGINT DEFAULT 84600,
                ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,
                CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_VALIDATORS (
        APP_ID INTEGER NOT NULL,
        SCOPE_VALIDATOR VARCHAR (128) NOT NULL,
        PRIMARY KEY (APP_ID,SCOPE_VALIDATOR),
        FOREIGN KEY (APP_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (
                REQUEST_TOKEN VARCHAR(255),
                REQUEST_TOKEN_SECRET VARCHAR(512),
                CONSUMER_KEY_ID INTEGER,
                CALLBACK_URL VARCHAR(1024),
                SCOPE VARCHAR(2048),
                AUTHORIZED VARCHAR(128),
                OAUTH_VERIFIER VARCHAR(512),
                AUTHZ_USER VARCHAR(512),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (REQUEST_TOKEN),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (
                ACCESS_TOKEN VARCHAR(255),
                ACCESS_TOKEN_SECRET VARCHAR(512),
                CONSUMER_KEY_ID INTEGER,
                SCOPE VARCHAR(2048),
                AUTHZ_USER VARCHAR(512),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ACCESS_TOKEN),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (
                TOKEN_ID VARCHAR (255),
                ACCESS_TOKEN VARCHAR(2048),
                REFRESH_TOKEN VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                USER_TYPE VARCHAR (25),
                GRANT_TYPE VARCHAR (50),
                TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                VALIDITY_PERIOD BIGINT,
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
                TOKEN_SCOPE_HASH VARCHAR(32),
                TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',
                TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',
                SUBJECT_IDENTIFIER VARCHAR(255),
                ACCESS_TOKEN_HASH VARCHAR(512),
                REFRESH_TOKEN_HASH VARCHAR(512),
                PRIMARY KEY (TOKEN_ID),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
                CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,
                                               TOKEN_STATE,TOKEN_STATE_ID)
    )ENGINE INNODB;
    CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);
    CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);
    CREATE INDEX IDX_ATH ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN_HASH);
    CREATE INDEX IDX_AT_TI_UD ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, TOKEN_STATE, USER_DOMAIN);
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_AUDIT (
                TOKEN_ID VARCHAR (255),
                ACCESS_TOKEN VARCHAR(2048),
                REFRESH_TOKEN VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                USER_TYPE VARCHAR (25),
                GRANT_TYPE VARCHAR (50),
                TIME_CREATED TIMESTAMP NULL,
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NULL,
                VALIDITY_PERIOD BIGINT,
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,
                TOKEN_SCOPE_HASH VARCHAR(32),
                TOKEN_STATE VARCHAR(25),
                TOKEN_STATE_ID VARCHAR (128) ,
                SUBJECT_IDENTIFIER VARCHAR(255),
                ACCESS_TOKEN_HASH VARCHAR(512),
                REFRESH_TOKEN_HASH VARCHAR(512),
                INVALIDATED_TIME TIMESTAMP NULL
    );
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (
                CODE_ID VARCHAR (255),
                AUTHORIZATION_CODE VARCHAR(2048),
                CONSUMER_KEY_ID INTEGER,
                CALLBACK_URL VARCHAR(1024),
                SCOPE VARCHAR(2048),
                AUTHZ_USER VARCHAR (100),
                TENANT_ID INTEGER,
                USER_DOMAIN VARCHAR(50),
                TIME_CREATED TIMESTAMP,
                VALIDITY_PERIOD BIGINT,
                STATE VARCHAR (25) DEFAULT 'ACTIVE',
                TOKEN_ID VARCHAR(255),
                SUBJECT_IDENTIFIER VARCHAR(255),
                PKCE_CODE_CHALLENGE VARCHAR(255),
                PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),
                AUTHORIZATION_CODE_HASH VARCHAR(512),
                PRIMARY KEY (CODE_ID),
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE INDEX IDX_AUTHORIZATION_CODE_HASH ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE_HASH,CONSUMER_KEY_ID);
    CREATE INDEX IDX_AUTHORIZATION_CODE_AU_TI ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHZ_USER,TENANT_ID, USER_DOMAIN, STATE);
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE (
                TOKEN_ID VARCHAR (255),
                TOKEN_SCOPE VARCHAR (60),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),
                FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE (
                SCOPE_ID INTEGER NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255) NOT NULL,
                DESCRIPTION VARCHAR(512),
                TENANT_ID INTEGER NOT NULL DEFAULT -1,
                PRIMARY KEY (SCOPE_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_BINDING (
                SCOPE_ID INTEGER NOT NULL,
                SCOPE_BINDING VARCHAR(255),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE(SCOPE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_RESOURCE_SCOPE (
                RESOURCE_PATH VARCHAR(255) NOT NULL,
                SCOPE_ID INTEGER NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (RESOURCE_PATH),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_SCIM_GROUP (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                ROLE_NAME VARCHAR(255) NOT NULL,
                ATTR_NAME VARCHAR(1024) NOT NULL,
                ATTR_VALUE VARCHAR(1024),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME);
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN_AN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME, ATTR_NAME);
    CREATE TABLE IF NOT EXISTS IDN_OPENID_REMEMBER_ME (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT 0,
                COOKIE_VALUE VARCHAR(1024),
                CREATED_TIME TIMESTAMP,
                PRIMARY KEY (USER_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT 0,
                RP_URL VARCHAR(255) NOT NULL,
                TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',
                LAST_VISIT DATE NOT NULL,
                VISIT_COUNT INTEGER DEFAULT 0,
                DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',
                PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OPENID_ASSOCIATIONS (
                HANDLE VARCHAR(255) NOT NULL,
                ASSOC_TYPE VARCHAR(255) NOT NULL,
                EXPIRE_IN TIMESTAMP NOT NULL,
                MAC_KEY VARCHAR(255) NOT NULL,
                ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (HANDLE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_STS_STORE (
                ID INTEGER AUTO_INCREMENT,
                TOKEN_ID VARCHAR(255) NOT NULL,
                TOKEN_CONTENT BLOB(1024) NOT NULL,
                CREATE_DATE TIMESTAMP NOT NULL,
                EXPIRE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                STATE INTEGER DEFAULT 0,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_USER_DATA (
                TENANT_ID INTEGER DEFAULT -1234,
                USER_NAME VARCHAR(255) NOT NULL,
                DATA_KEY VARCHAR(255) NOT NULL,
                DATA_VALUE VARCHAR(2048),
                PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_META_DATA (
                USER_NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1234,
                METADATA_TYPE VARCHAR(255) NOT NULL,
                METADATA VARCHAR(255) NOT NULL,
                VALID VARCHAR(255) NOT NULL,
                PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (
                SESSION_ID VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                CREATED_TIME VARCHAR(255) NOT NULL,
                LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (SESSION_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_AUTH_SESSION_STORE (
                SESSION_ID VARCHAR (100) NOT NULL,
                SESSION_TYPE VARCHAR(100) NOT NULL,
                OPERATION VARCHAR(10) NOT NULL,
                SESSION_OBJECT BLOB,
                TIME_CREATED BIGINT,
                TENANT_ID INTEGER DEFAULT -1,
                EXPIRY_TIME BIGINT,
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_AUTH_SESSION_TIME ON IDN_AUTH_SESSION_STORE (TIME_CREATED);
    CREATE TABLE IF NOT EXISTS IDN_AUTH_TEMP_SESSION_STORE (
                SESSION_ID VARCHAR (100) NOT NULL,
                SESSION_TYPE VARCHAR(100) NOT NULL,
                OPERATION VARCHAR(10) NOT NULL,
                SESSION_OBJECT BLOB,
                TIME_CREATED BIGINT,
                TENANT_ID INTEGER DEFAULT -1,
                EXPIRY_TIME BIGINT,
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)
    )ENGINE INNODB;
    CREATE INDEX IDX_IDN_AUTH_TMP_SESSION_TIME ON IDN_AUTH_TEMP_SESSION_STORE (TIME_CREATED);
    CREATE TABLE IF NOT EXISTS SP_APP (
            ID INTEGER NOT NULL AUTO_INCREMENT,
            TENANT_ID INTEGER NOT NULL,
                APP_NAME VARCHAR (255) NOT NULL ,
                USER_STORE VARCHAR (255) NOT NULL,
            USERNAME VARCHAR (255) NOT NULL ,
            DESCRIPTION VARCHAR (1024),
                ROLE_CLAIM VARCHAR (512),
            AUTH_TYPE VARCHAR (255) NOT NULL,
                PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),
                IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',
                IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',
                IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',
            IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',
            ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',
                SUBJECT_CLAIM_URI VARCHAR (512),
                IS_SAAS_APP CHAR(1) DEFAULT '0',
                IS_DUMB_MODE CHAR(1) DEFAULT '0',
            PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);
    CREATE TABLE IF NOT EXISTS SP_METADATA (
                ID INTEGER AUTO_INCREMENT,
                SP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                VALUE VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID),
                CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),
                FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS SP_INBOUND_AUTH (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                INBOUND_AUTH_KEY VARCHAR (255),
                INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,
                INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,
                PROP_NAME VARCHAR (255),
                PROP_VALUE VARCHAR (1024) ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_AUTH_STEP (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                STEP_ORDER INTEGER DEFAULT 1,
                APP_ID INTEGER NOT NULL ,
                IS_SUBJECT_STEP CHAR(1) DEFAULT '0',
                IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_FEDERATED_IDP (
                ID INTEGER NOT NULL,
                TENANT_ID INTEGER NOT NULL,
                AUTHENTICATOR_ID INTEGER NOT NULL,
                PRIMARY KEY (ID, AUTHENTICATOR_ID)
    )ENGINE INNODB;
    ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_CLAIM_DIALECT (
            ID INTEGER NOT NULL AUTO_INCREMENT,
            TENANT_ID INTEGER NOT NULL,
            SP_DIALECT VARCHAR (512) NOT NULL,
            APP_ID INTEGER NOT NULL,
            PRIMARY KEY (ID));
    ALTER TABLE SP_CLAIM_DIALECT ADD CONSTRAINT DIALECTID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_CLAIM_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_CLAIM VARCHAR (512) NOT NULL ,
                SP_CLAIM VARCHAR (512) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
            IS_MANDATORY VARCHAR(128) DEFAULT '0',
                DEFAULT_VALUE VARCHAR(255),
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_ROLE_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_ROLE VARCHAR (255) NOT NULL ,
                SP_ROLE VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_REQ_PATH_AUTHENTICATOR (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE IF NOT EXISTS SP_PROVISIONING_CONNECTOR (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                TENANT_ID INTEGER NOT NULL,
                IDP_NAME VARCHAR (255) NOT NULL ,
                CONNECTOR_NAME VARCHAR (255) NOT NULL ,
                APP_ID INTEGER NOT NULL,
                IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',
                BLOCKING CHAR(1) NOT NULL DEFAULT '0',
                RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;
    CREATE TABLE SP_AUTH_SCRIPT (
      ID         INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID  INTEGER                NOT NULL,
      APP_ID     INTEGER                NOT NULL,
      TYPE       VARCHAR(255)           NOT NULL,
      CONTENT    BLOB    DEFAULT NULL,
      IS_ENABLED CHAR(1) NOT NULL DEFAULT '0',
      PRIMARY KEY (ID));
    CREATE TABLE IF NOT EXISTS SP_TEMPLATE (
      ID         INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID  INTEGER                NOT NULL,
      NAME VARCHAR(255) NOT NULL,
      DESCRIPTION VARCHAR(1023),
      CONTENT BLOB DEFAULT NULL,
      PRIMARY KEY (ID),
      CONSTRAINT SP_TEMPLATE_CONSTRAINT UNIQUE (TENANT_ID, NAME));
    CREATE INDEX IDX_SP_TEMPLATE ON SP_TEMPLATE (TENANT_ID, NAME);
    CREATE TABLE IF NOT EXISTS IDN_AUTH_WAIT_STATUS (
      ID              INTEGER AUTO_INCREMENT NOT NULL,
      TENANT_ID       INTEGER                NOT NULL,
      LONG_WAIT_KEY   VARCHAR(255)           NOT NULL,
      WAIT_STATUS     CHAR(1) NOT NULL DEFAULT '1',
      TIME_CREATED    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      EXPIRE_TIME     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (ID),
      CONSTRAINT IDN_AUTH_WAIT_STATUS_KEY UNIQUE (LONG_WAIT_KEY));
    CREATE TABLE IF NOT EXISTS IDP (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                NAME VARCHAR(254) NOT NULL,
                IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',
                IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',
                HOME_REALM_ID VARCHAR(254),
                IMAGE MEDIUMBLOB,
                CERTIFICATE BLOB,
                ALIAS VARCHAR(254),
                INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',
                INBOUND_PROV_USER_STORE_ID VARCHAR(254),
                USER_CLAIM_URI VARCHAR(254),
                ROLE_CLAIM_URI VARCHAR(254),
                DESCRIPTION VARCHAR (1024),
                DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),
                DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),
                PROVISIONING_ROLE VARCHAR(128),
                IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',
                IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',
                DISPLAY_NAME VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, NAME)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_ROLE (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                TENANT_ID INTEGER,
                ROLE VARCHAR(254),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ID, ROLE),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_ROLE_MAPPING (
                ID INTEGER AUTO_INCREMENT,
                IDP_ROLE_ID INTEGER,
                TENANT_ID INTEGER,
                USER_STORE_ID VARCHAR (253),
                LOCAL_ROLE VARCHAR(253),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),
                FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_CLAIM (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                TENANT_ID INTEGER,
                CLAIM VARCHAR(254),
                PRIMARY KEY (ID),
                UNIQUE (IDP_ID, CLAIM),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_CLAIM_MAPPING (
                ID INTEGER AUTO_INCREMENT,
                IDP_CLAIM_ID INTEGER,
                TENANT_ID INTEGER,
                LOCAL_CLAIM VARCHAR(253),
                DEFAULT_VALUE VARCHAR(255),
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),
                FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                IS_ENABLED CHAR (1) DEFAULT '1',
                DISPLAY_NAME VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, NAME),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_METADATA (
                ID INTEGER AUTO_INCREMENT,
                IDP_ID INTEGER,
                NAME VARCHAR(255) NOT NULL,
                VALUE VARCHAR(255) NOT NULL,
                DISPLAY_NAME VARCHAR(255),
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID),
                CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR_PROPERTY (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                AUTHENTICATOR_ID INTEGER,
                PROPERTY_KEY VARCHAR(255) NOT NULL,
                PROPERTY_VALUE VARCHAR(2047),
                IS_SECRET CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),
                FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_CONFIG (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,
                IS_ENABLED CHAR (1) DEFAULT '0',
                IS_BLOCKING CHAR (1) DEFAULT '0',
                IS_RULES_ENABLED CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROV_CONFIG_PROPERTY (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                PROVISIONING_CONFIG_ID INTEGER,
                PROPERTY_KEY VARCHAR(255) NOT NULL,
                PROPERTY_VALUE VARCHAR(2048),
                PROPERTY_BLOB_VALUE BLOB,
                PROPERTY_TYPE CHAR(32) NOT NULL,
                IS_SECRET CHAR (1) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_ENTITY (
                ID INTEGER AUTO_INCREMENT,
                PROVISIONING_CONFIG_ID INTEGER,
                ENTITY_TYPE VARCHAR(255) NOT NULL,
                ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,
                ENTITY_NAME VARCHAR(255) NOT NULL,
                ENTITY_VALUE VARCHAR(255),
                TENANT_ID INTEGER,
                ENTITY_LOCAL_ID VARCHAR(255),
                PRIMARY KEY (ID),
                UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),
                UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDP_LOCAL_CLAIM (
                ID INTEGER AUTO_INCREMENT,
                TENANT_ID INTEGER,
                IDP_ID INTEGER,
                CLAIM_URI VARCHAR(255) NOT NULL,
                DEFAULT_VALUE VARCHAR(255),
                IS_REQUESTED VARCHAR(128) DEFAULT '0',
                PRIMARY KEY (ID),
                UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_ASSOCIATED_ID (
                ID INTEGER AUTO_INCREMENT,
                IDP_USER_ID VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1234,
                IDP_ID INTEGER NOT NULL,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                PRIMARY KEY (ID),
                UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_USER_ACCOUNT_ASSOCIATION (
                ASSOCIATION_KEY VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(255) NOT NULL,
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS FIDO_DEVICE_STORE (
                TENANT_ID INTEGER,
                DOMAIN_NAME VARCHAR(255) NOT NULL,
                USER_NAME VARCHAR(45) NOT NULL,
                TIME_REGISTERED TIMESTAMP,
                KEY_HANDLE VARCHAR(200) NOT NULL,
                DEVICE_DATA VARCHAR(2048) NOT NULL,
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE)
            )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_REQUEST (
        UUID VARCHAR (45),
        CREATED_BY VARCHAR (255),
        TENANT_ID INTEGER DEFAULT -1,
        OPERATION_TYPE VARCHAR (50),
        CREATED_AT TIMESTAMP,
        UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        STATUS VARCHAR (30),
        REQUEST BLOB,
        PRIMARY KEY (UUID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_BPS_PROFILE (
        PROFILE_NAME VARCHAR(45),
        HOST_URL_MANAGER VARCHAR(255),
        HOST_URL_WORKER VARCHAR(255),
        USERNAME VARCHAR(45),
        PASSWORD VARCHAR(1023),
        CALLBACK_HOST VARCHAR (45),
        CALLBACK_USERNAME VARCHAR (45),
        CALLBACK_PASSWORD VARCHAR (255),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (PROFILE_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW(
        ID VARCHAR (45),
        WF_NAME VARCHAR (45),
        DESCRIPTION VARCHAR (255),
        TEMPLATE_ID VARCHAR (45),
        IMPL_ID VARCHAR (45),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_ASSOCIATION(
        ID INTEGER NOT NULL AUTO_INCREMENT,
        ASSOC_NAME VARCHAR (45),
        EVENT_ID VARCHAR(45),
        ASSOC_CONDITION VARCHAR (2000),
        WORKFLOW_ID VARCHAR (45),
        IS_ENABLED CHAR (1) DEFAULT '1',
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY(ID),
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_CONFIG_PARAM(
        WORKFLOW_ID VARCHAR (45),
        PARAM_NAME VARCHAR (45),
        PARAM_VALUE VARCHAR (1000),
        PARAM_QNAME VARCHAR (45),
        PARAM_HOLDER VARCHAR (45),
        TENANT_ID INTEGER DEFAULT -1,
        PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_REQUEST_ENTITY_RELATIONSHIP(
      REQUEST_ID VARCHAR (45),
      ENTITY_NAME VARCHAR (255),
      ENTITY_TYPE VARCHAR (50),
      TENANT_ID INTEGER DEFAULT -1,
      PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_REQUEST_RELATION(
      RELATIONSHIP_ID VARCHAR (45),
      WORKFLOW_ID VARCHAR (45),
      REQUEST_ID VARCHAR (45),
      UPDATED_AT TIMESTAMP,
      STATUS VARCHAR (30),
      TENANT_ID INTEGER DEFAULT -1,
      PRIMARY KEY (RELATIONSHIP_ID),
      FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_RECOVERY_DATA (
      USER_NAME VARCHAR(255) NOT NULL,
      USER_DOMAIN VARCHAR(127) NOT NULL,
      TENANT_ID INTEGER DEFAULT -1,
      CODE VARCHAR(255) NOT NULL,
      SCENARIO VARCHAR(255) NOT NULL,
      STEP VARCHAR(127) NOT NULL,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      REMAINING_SETS VARCHAR(2500) DEFAULT NULL,
      PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),
      UNIQUE(CODE)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_PASSWORD_HISTORY_DATA (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      USER_NAME   VARCHAR(255) NOT NULL,
      USER_DOMAIN VARCHAR(127) NOT NULL,
      TENANT_ID   INTEGER DEFAULT -1,
      SALT_VALUE  VARCHAR(255),
      HASH        VARCHAR(255) NOT NULL,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY(ID),
      UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_DIALECT (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      DIALECT_URI VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      DIALECT_ID INTEGER,
      CLAIM_URI VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,
      CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPED_ATTRIBUTE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      LOCAL_CLAIM_ID INTEGER,
      USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,
      ATTRIBUTE_NAME VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_PROPERTY (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      LOCAL_CLAIM_ID INTEGER,
      PROPERTY_NAME VARCHAR (255) NOT NULL,
      PROPERTY_VALUE VARCHAR (255) NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPING (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      EXT_CLAIM_ID INTEGER NOT NULL,
      MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,
      TENANT_ID INTEGER NOT NULL,
      PRIMARY KEY (ID),
      FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,
      CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS  IDN_SAML2_ASSERTION_STORE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      SAML2_ID  VARCHAR(255) ,
      SAML2_ISSUER  VARCHAR(255) ,
      SAML2_SUBJECT  VARCHAR(255) ,
      SAML2_SESSION_INDEX  VARCHAR(255) ,
      SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,
      SAML2_ASSERTION  VARCHAR(4096) ,
      PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IDN_SAML2_ARTIFACT_STORE (
      ID INT(11) NOT NULL AUTO_INCREMENT,
      SOURCE_ID VARCHAR(255) NOT NULL,
      MESSAGE_HANDLER VARCHAR(255) NOT NULL,
      AUTHN_REQ_DTO BLOB NOT NULL,
      SESSION_ID VARCHAR(255) NOT NULL,
      EXP_TIMESTAMP TIMESTAMP NOT NULL,
      INIT_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      ASSERTION_ID VARCHAR(255),
      PRIMARY KEY (`ID`)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_JTI (
      JWT_ID VARCHAR(255) NOT NULL,
      EXP_TIME TIMESTAMP NOT NULL ,
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
      PRIMARY KEY (JWT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS  IDN_OIDC_PROPERTY (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      TENANT_ID  INTEGER,
      CONSUMER_KEY  VARCHAR(255) ,
      PROPERTY_KEY  VARCHAR(255) NOT NULL,
      PROPERTY_VALUE  VARCHAR(2047) ,
      PRIMARY KEY (ID),
      FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_REFERENCE (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      CONSUMER_KEY_ID INTEGER ,
      CODE_ID VARCHAR(255) ,
      TOKEN_ID VARCHAR(255) ,
      SESSION_DATA_KEY VARCHAR(255),
      PRIMARY KEY (ID),
      FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,
      FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE,
      FOREIGN KEY (CODE_ID) REFERENCES IDN_OAUTH2_AUTHORIZATION_CODE(CODE_ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_CLAIMS (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      REQ_OBJECT_ID INTEGER,
      CLAIM_ATTRIBUTE VARCHAR(255) ,
      ESSENTIAL CHAR(1) NOT NULL DEFAULT '0' ,
      VALUE VARCHAR(255) ,
      IS_USERINFO CHAR(1) NOT NULL DEFAULT '0',
      PRIMARY KEY (ID),
      FOREIGN KEY (REQ_OBJECT_ID) REFERENCES IDN_OIDC_REQ_OBJECT_REFERENCE (ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJ_CLAIM_VALUES (
      ID INTEGER NOT NULL AUTO_INCREMENT,
      REQ_OBJECT_CLAIMS_ID INTEGER ,
      CLAIM_VALUES VARCHAR(255) ,
      PRIMARY KEY (ID),
      FOREIGN KEY (REQ_OBJECT_CLAIMS_ID) REFERENCES  IDN_OIDC_REQ_OBJECT_CLAIMS(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_CERTIFICATE (
                 ID INTEGER NOT NULL AUTO_INCREMENT,
                 NAME VARCHAR(100),
                 CERTIFICATE_IN_PEM BLOB,
                 TENANT_ID INTEGER DEFAULT 0,
                 PRIMARY KEY(ID),
                 CONSTRAINT CERTIFICATE_UNIQUE_KEY UNIQUE (NAME, TENANT_ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                NAME VARCHAR(255) NOT NULL,
                TENANT_ID INTEGER DEFAULT -1,
                PRIMARY KEY (ID)
    )ENGINE INNODB;
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE_CLAIM_MAPPING (
                ID INTEGER NOT NULL AUTO_INCREMENT,
                SCOPE_ID INTEGER,
                EXTERNAL_CLAIM_ID INTEGER,
                PRIMARY KEY (ID),
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OIDC_SCOPE(ID) ON DELETE CASCADE,
                FOREIGN KEY (EXTERNAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE
    )ENGINE INNODB;
    CREATE INDEX IDX_AT_SI_ECI ON IDN_OIDC_SCOPE_CLAIM_MAPPING(SCOPE_ID, EXTERNAL_CLAIM_ID);
kind: ConfigMap
metadata:
  name: mysql-dbscripts
  namespace: "$ns.k8s&wso2.is"
---

apiVersion: v1
kind: Service
metadata:
  name: wso2is-rdbms-service
  namespace: "$ns.k8s&wso2.is"
spec:
  type: ClusterIP
  selector:
    deployment: wso2is-mysql
  ports:
    - name: mysql-port
      port: 3306
      targetPort: 3306
      protocol: TCP
---

apiVersion: v1
kind: Service
metadata:
  name: wso2is-is-service
  namespace: "$ns.k8s&wso2.is"
  labels:
    deployment: wso2is-is
spec:
  selector:
    deployment: wso2is-is
  type: NodePort
  ports:
    - name: servlet-http
      port: 9763
      targetPort: 9763
      protocol: TCP
    - name: servlet-https
      port: 9443
      targetPort: 9443
      protocol: TCP
      nodePort: "$nodeport.k8s.&.1.wso2is"
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wso2is-mysql-deployment
  namespace: "$ns.k8s&wso2.is"
spec:
  replicas: 1
  selector:
    matchLabels:
      deployment: wso2is-mysql
      pod: wso2is
  template:
    metadata:
      labels:
        deployment: wso2is-mysql
        pod: wso2is
    spec:
      containers:
        - name: wso2is-mysql
          image: mysql:5.7
          livenessProbe:
            exec:
              command:
                - sh
                - -c
                - "mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}"
            initialDelaySeconds: 60
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - sh
                - -c
                - "mysqladmin ping -u root -p${MYSQL_ROOT_PASSWORD}"
            initialDelaySeconds: 60
            periodSeconds: 10
          imagePullPolicy: IfNotPresent
          securityContext:
            runAsUser: 999
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: root
            - name: MYSQL_USER
              value: wso2carbon
            - name: MYSQL_PASSWORD
              value: wso2carbon
          ports:
            - containerPort: 3306
              protocol: TCP
          volumeMounts:
            - name: mysql-dbscripts
              mountPath: /docker-entrypoint-initdb.d
          args: ["--max-connections", "10000"]
      volumes:
        - name: mysql-dbscripts
          configMap:
            name: mysql-dbscripts
      serviceAccountName: "wso2svc-account"
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: wso2is-is-deployment
  namespace: "$ns.k8s&wso2.is"
spec:
  replicas: 1
  minReadySeconds: 30
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
    type: RollingUpdate
  selector:
    matchLabels:
      deployment: wso2is-is
      pod: wso2is
  template:
    metadata:
      labels:
        deployment: wso2is-is
        pod: wso2is
    spec:
      hostAliases:
        - ip: "127.0.0.1"
          hostnames:
            - "wso2is"
      containers:
        - name: wso2is-is
          image: "$image.pull.@.wso2"/wso2is:5.7.0
          livenessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - nc -z localhost 9443
            initialDelaySeconds: 60
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - /bin/sh
                - -c
                - nc -z localhost 9443
            initialDelaySeconds: 60
            periodSeconds: 10
          lifecycle:
            preStop:
              exec:
                command:  ['sh', '-c', '${WSO2_SERVER_HOME}/bin/wso2server.sh stop']
          imagePullPolicy: Always
          securityContext:
            runAsUser: 802
          ports:
            - containerPort: 9763
              protocol: TCP
            - containerPort: 9443
              protocol: TCP
          volumeMounts:
            - name: identity-server-conf
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf
            - name: identity-server-conf-datasources
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf/datasources
      initContainers:
        - name: init-is
          image: busybox
          command: ['sh', '-c', 'echo -e "checking for the availability of MySQL"; while ! nc -z wso2is-rdbms-service 3306; do sleep 1; printf "-"; done; echo -e "  >> MySQL started";']
      serviceAccountName: "wso2svc-account"
      imagePullSecrets:
        - name: wso2creds
      volumes:
        - name: identity-server-conf
          configMap:
            name: identity-server-conf
        - name: identity-server-conf-datasources
          configMap:
            name: identity-server-conf-datasources
---
EOF
}
function usage(){
  echo "Usage: "
  echo -e "-d, --deploy     Deploy WSO2 Identity Server"
  echo -e "-u, --undeploy   Undeploy WSO2 Identity Server"
  echo -e "-h, --help       Display usage instrusctions"
}
function undeploy(){
  echoBold "Undeploying WSO2 Identity Server ... \n"
  kubectl delete -f deployment.yaml
  exit 0
}
function echoBold () {
    echo -en  $'\e[1m'"${1}"$'\e[0m'
}

function st(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold "* "
    let "i=i+1"
  done
}
function sp(){
  cycles=${1}
  i=0
  while [[ i -lt $cycles ]]
  do
    echoBold " "
    let "i=i+1"
  done
}
function product_name(){
  #wso2is
  echo -e "\n"
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; sp 1; st 3; sp 3; sp 8; st 5; sp 2; sp 1; st 3; sp 3; echo ""
  st 1; sp 8; st 1; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 4; st 1; sp 2; sp 8; sp 4; st 1; sp 4; sp 2; st 1; sp 4; st 1; echo ""
  st 1; sp 3; st 1; sp 3; st 1; sp 2; st 1; sp 8; st 1; sp 6; st 1; sp 2; sp 6; st 1; sp 2; sp 8; sp 4; st 1; sp 4; sp 2; st 1; sp 8; echo ""
  st 1; sp 2; st 1; st 1; sp 2; st 1; sp 2; sp 1; st 3; sp 3; st 1; sp 6; st 1; sp 2; sp 4; st 1; sp 4; st 3; sp 2; sp 4; st 1; sp 4; sp 2; sp 1; st 3; sp 1; echo ""
  st 1; sp 1; st 1; sp 2; st 1; sp 1; st 1; sp 2; sp 6; st 1; sp 2; st 1; sp 6; st 1; sp 2; sp 2; st 1; sp 6; sp 8; sp 4; st 1; sp 4; sp 2; sp 6; st 1; echo ""
  st 2; sp 4; st 2; sp 2; st 1; sp 4; st 1; sp 2; st 1; sp 6; st 1; sp 2; st 1; sp 8; sp 8; sp 4; st 1; sp 4; sp 2; st 1; sp 4; st 1; echo ""
  st 1; sp 8; st 1; sp 2; sp 1; st 3; sp 3; sp 2; st 3; sp 4; st 4; sp 2; sp 8; st 5; sp 2; sp 1; st 3; sp 1; echo -e "\n"
}
function display_msg(){
    msg=$@
    echoBold "${msg}"
    exit 1
}
function validate_ip(){
    ip_check=$1
    if [[ $ip_check =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
      IFS='.'
      ip=$ip_check
      set -- $ip
      if [[ $1 -le 255 ]] && [[ $2 -le 255 ]] && [[ $3 -le 255 ]] && [[ $4 -le 255 ]]; then
        IFS=''
        NODE_IP=$ip_check
      else
        IFS=''
        echo "Invalid IP. Please try again."
        NODE_IP=""
      fi
    else
      echo "Invalid IP. Please try again."
      NODE_IP=""
    fi
}
function get_node_ip(){
  NODE_IP=$(kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}')

  if [[ -z $NODE_IP ]]
  then
      if [[ $(kubectl config current-context)="minikube" ]]
      then
          NODE_IP=$(minikube ip)
      else
        echo "We could not find your cluster node-ip."
        while [[ -z "$NODE_IP" ]]
        do
              read -p "$(echo "Enter one of your cluster Node IPs to provision instant access to server: ")" NODE_IP
              if [[ -z "$NODE_IP" ]]
              then
                echo "cluster node ip cannot be empty"
              else
                validate_ip $NODE_IP
              fi
        done
      fi
  fi
  set -- $NODE_IP; NODE_IP=$1
}
function get_nodePorts(){
  LOWER=30000; UPPER=32767;
  if [ "$randomPort" == "True" ]; then
    NP_1=0;
    while [ $NP_1 -lt $LOWER ]
    do
      NP_1=$RANDOM
      let "NP_1 %= $UPPER"
    done
  fi
  echo -e "[INFO] nodePorts  are set to $NP_1"
}
function progress_bar(){
  dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.pod=="wso2is")].status.conditions[?(@.type=="Available")].status}')
  pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.pod=="wso2is")].status.conditions[*].status}')

  num_true_const=0; progress_unit="";time_proc=0;

  arr_dep=($dep_status); arr_pod=($pod_status)

  let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

  echo ""

  while [[ $num_true -lt $length_total ]]
  do
      sleep 4
      num_true=0
      dep_status=$(kubectl get deployments -n wso2 -o jsonpath='{.items[?(@.spec.selector.matchLabels.pod=="wso2is")].status.conditions[?(@.type=="Available")].status}')
      pod_status=$(kubectl get pods -n wso2 -o jsonpath='{.items[?(@.metadata.labels.pod=="wso2is")].status.conditions[*].status}')

      arr_dep=($dep_status); arr_pod=($pod_status); let "length_total= ${#arr_pod[@]} + ${#arr_dep[@]}";

      for ele_dep in $dep_status
      do
          if [ "$ele_dep" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      for ele_pod in $pod_status
      do
          if [ "$ele_pod" = "True" ]
          then
              let "num_true=num_true+1"
          fi
      done

      printf "Processing WSO2 Identity Server ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' %\r'

      printf "Processing WSO2 Identity Server ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' %\r '

      if [ $num_true -ne $num_true_const ]
      then
          i=0
          while [[ $i -lt  $((5 * $((${num_true} - ${num_true_const})))) ]]
          do
              let "i=i+1"
              progress_unit=$progress_unit"H"
              printf "Processing WSO2 Identity Server ... |"
              echo -n $progress_unit
              printf "%-$((5 * $((${length_total} - ${num_true_const})) - $i))s| $(($(( 100 * $(($num_true_const))/ $length_total)) + 2 * $i ))"; echo -en ' %\r '
              sleep 0.25
          done
          num_true_const=$num_true
          time_proc=0
      else
          let "time_proc=time_proc + 5"
      fi
      printf "Processing WSO2 Identity Server ... |"

      printf "%-$((5 * ${length_total-1}))s| $(($num_true_const * 100/ $length_total))"; echo -en ' %\r '

      printf "Processing WSO2 Identity Server ... |"
      s=$(printf "%-$((5 * ${num_true_const}))s" "H")
      echo -en "${s// /H}"

      printf "%-$((5 * $(($length_total - $num_true_const))))s| $((100 * $(($num_true_const))/ $length_total))"; echo -en ' % \r'

      sleep 1

      if [[ $time_proc -gt 250 ]]
      then
          echoBold "\nSomething went wrong! Please Follow <FAQ> for more information\n"
          exit 2
      fi
  done

  echo -e "\n"

}
function deploy(){

    #checking for required tools
    if [[ ! $(which kubectl) ]]
    then
       display_msg "Please install Kubernetes command-line tool (kubectl) before you start with the setup\n"
    fi

    if [[ ! $(which base64) ]]
    then
       display_msg "Please install base64 before you start with the setup\n"
    fi

    echoBold "Checking for an enabled cluster... Your patience is appreciated..."
    cluster_isReady=$(kubectl cluster-info) > /dev/null 2>&1  || true

    if [[ ! $cluster_isReady == *"KubeDNS"* ]]
    then
        echoBold "Done.\n"
        display_msg "\nPlease enable your cluster before running the setup.\n\nIf you don't have a kubernetes cluster, follow: https://kubernetes.io/docs/setup/\n\n"
    fi
    echoBold "Done.\n"

    #displaying wso2 product name
    product_name

    if test -f $TG_PROP; then
        source $TG_PROP
    fi

    # getting cluster node ip
    get_node_ip

    # if TG randomPort else default
    get_nodePorts

    #create kubernetes object yaml
    create_yaml

    # replace placeholders
    sed -i '' 's/"$ns.k8s&wso2.is"/'$namespace'/g' $k8s_obj_file
    sed -i '' 's/"$string.&.secret.auth.data"/'$secdata'/g' $k8s_obj_file
    sed -i '' 's/"$nodeport.k8s.&.1.wso2is"/'$NP_1'/g' $k8s_obj_file
    sed -i '' 's/"$image.pull.@.wso2"/'$IMG_DEST'/g' $k8s_obj_file

    if ! test -f $TG_PROP; then
        echoBold "\nDeploying WSO2 Identity Server...\n"

        # create kubernetes deployment
        kubectl create -f ${k8s_obj_file}

        # waiting until deployment is ready
        progress_bar

        echoBold "Successfully deployed WSO2 Identity Server.\n\n"

        echoBold "1. Try navigating to https://$NODE_IP:30443/carbon/ from your favourite browser using \n"
        echoBold "\tusername: admin\n"
        echoBold "\tpassword: admin\n"
        echoBold "2. Follow \"https://docs.wso2.com/display/IS570\" to start using WSO2 Identity Server.\n\n "
    fi
}
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
