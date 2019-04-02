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

ECHO=`which echo`

# methods
function echoBold () {
    ${ECHO} -e $'\e[1m'"${1}"$'\e[0m'
}

# get wso2 credentials
WSO2_SUBSCRIPTION_USERNAME=''
WSO2_SUBSCRIPTION_PASSWORD=''

echoBold "Enter your wso2 subscription username"
read -p "USERNAME: " WSO2_SUBSCRIPTION_USERNAME
echoBold "Enter your wso2 subscription password"
read -sp "PASSWORD: " WSO2_SUBSCRIPTION_PASSWORD

echo ""

# create and encode username/password pair
auth="$WSO2_SUBSCRIPTION_USERNAME:$WSO2_SUBSCRIPTION_PASSWORD"
authb64=`echo -n $auth | base64`

# create authorisation code
authstring='{"auths":{"docker.wso2.com": {"username":"'$WSO2_SUBSCRIPTION_USERNAME'","password":"'$WSO2_SUBSCRIPTION_PASSWORD'","email":"'$WSO2_SUBSCRIPTION_USERNAME'","auth":"'$authb64'"}}}'

# encode in base64
secdata=`echo -n $authstring | base64`

echo -e "apiVersion: v1\n\
kind: Namespace\n\
metadata:\n\
  name: wso2\n\
spec:\n\
  finalizers:\n\
    - kubernetes\n\
---\n" > deployment.yaml

echo -e "apiVersion: v1\n\
kind: ServiceAccount\n\
metadata:\n\
  name: wso2svc-account\n\
  namespace: wso2\n\
secrets:\n\
  - name: wso2svc-account-token-t7s49\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  .dockerconfigjson: $secdata\n\
kind: Secret\n\
metadata:\n\
  name: wso2creds\n\
  namespace: wso2\n\
type: kubernetes.io/dockerconfigjson\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  carbon.xml: |\n\
    <?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n\
    <Server xmlns=\"http://wso2.org/projects/carbon/carbon.xml\">\n\
        <Name>WSO2 Identity Server</Name>\n\
        <ServerKey>IS</ServerKey>\n\
        <Version>5.7.0</Version>\n\
        <HostName>wso2is</HostName>\n\
        <MgtHostName>wso2is</MgtHostName>\n\
        <ServerURL>local:/\${carbon.context}/services/</ServerURL>\n\
        <ServerRoles>\n\
            <Role>IdentityServer</Role>\n\
        </ServerRoles>\n\
        <Package>org.wso2.carbon</Package>\n\
        <WebContextRoot>/</WebContextRoot>\n\
        <ItemsPerPage>15</ItemsPerPage>\n\
        <Ports>\n\
            <Offset>0</Offset>\n\
            <JMX>\n\
                <RMIRegistryPort>9999</RMIRegistryPort>\n\
                <RMIServerPort>11111</RMIServerPort>\n\
            </JMX>\n\
            <EmbeddedLDAP>\n\
                <LDAPServerPort>10389</LDAPServerPort>\n\
                <KDCServerPort>8000</KDCServerPort>\n\
            </EmbeddedLDAP>\n\
    	<ThriftEntitlementReceivePort>10500</ThriftEntitlementReceivePort>\n\
        </Ports>\n\
        <JNDI>\n\
            <DefaultInitialContextFactory>org.wso2.carbon.tomcat.jndi.CarbonJavaURLContextFactory</DefaultInitialContextFactory>\n\
            <Restrictions>\n\
                <AllTenants>\n\
                    <UrlContexts>\n\
                        <UrlContext>\n\
                            <Scheme>java</Scheme>\n\
                        </UrlContext>\n\
                    </UrlContexts>\n\
                </AllTenants>\n\
            </Restrictions>\n\
        </JNDI>\n\
        <IsCloudDeployment>false</IsCloudDeployment>\n\
        <EnableMetering>false</EnableMetering>\n\
        <MaxThreadExecutionTime>600</MaxThreadExecutionTime>\n\
        <GhostDeployment>\n\
            <Enabled>false</Enabled>\n\
        </GhostDeployment>\n\
        <Tenant>\n\
            <LoadingPolicy>\n\
                <LazyLoading>\n\
                    <IdleTime>30</IdleTime>\n\
                </LazyLoading>\n\
            </LoadingPolicy>\n\
        </Tenant>\n\
        <Cache>\n\
            <DefaultCacheTimeout>15</DefaultCacheTimeout>\n\
            <ForceLocalCache>false</ForceLocalCache>\n\
        </Cache>\n\
        <Axis2Config>\n\
            <RepositoryLocation>\${carbon.home}/repository/deployment/server/</RepositoryLocation>\n\
            <DeploymentUpdateInterval>15</DeploymentUpdateInterval>\n\
            <ConfigurationFile>\${carbon.home}/repository/conf/axis2/axis2.xml</ConfigurationFile>\n\
            <ServiceGroupContextIdleTime>30000</ServiceGroupContextIdleTime>\n\
            <clientAxis2XmlLocation>\${carbon.home}/repository/conf/axis2/axis2_client.xml</clientAxis2XmlLocation>\n\
            <HideAdminServiceWSDLs>true</HideAdminServiceWSDLs>\n\
       </Axis2Config>\n\
        <ServiceUserRoles>\n\
            <Role>\n\
                <Name>admin</Name>\n\
                <Description>Default Administrator Role</Description>\n\
            </Role>\n\
            <Role>\n\
                <Name>user</Name>\n\
                <Description>Default User Role</Description>\n\
            </Role>\n\
        </ServiceUserRoles>\n\
        <CryptoService>\n\
            <Enabled>true</Enabled>\n\
            <InternalCryptoProviderClassName>org.wso2.carbon.crypto.provider.KeyStoreBasedInternalCryptoProvider</InternalCryptoProviderClassName>\n\
            <ExternalCryptoProviderClassName>org.wso2.carbon.core.encryption.KeyStoreBasedExternalCryptoProvider</ExternalCryptoProviderClassName>\n\
            <KeyResolvers>\n\
                <KeyResolver className=\"org.wso2.carbon.crypto.defaultProvider.resolver.ContextIndependentKeyResolver\" priority=\"-1\"/>\n\
            </KeyResolvers>\n\
        </CryptoService>\n\
        <Security>\n\
            <KeyStore>\n\
                <Location>\${carbon.home}/repository/resources/security/wso2carbon.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
                <KeyAlias>wso2carbon</KeyAlias>\n\
                <KeyPassword>wso2carbon</KeyPassword>\n\
            </KeyStore>\n\
            <InternalKeyStore>\n\
                <Location>\${carbon.home}/repository/resources/security/wso2carbon.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
                <KeyAlias>wso2carbon</KeyAlias>\n\
                <KeyPassword>wso2carbon</KeyPassword>\n\
            </InternalKeyStore>\n\
            <TrustStore>\n\
                <Location>\${carbon.home}/repository/resources/security/client-truststore.jks</Location>\n\
                <Type>JKS</Type>\n\
                <Password>wso2carbon</Password>\n\
            </TrustStore>\n\
            <NetworkAuthenticatorConfig>\n\
            </NetworkAuthenticatorConfig>\n\
            <TomcatRealm>UserManager</TomcatRealm>\n\
    	<DisableTokenStore>false</DisableTokenStore>\n\
     <STSCallBackHandlerName>org.wso2.carbon.identity.provider.AttributeCallbackHandler</STSCallBackHandlerName>\n\
    	<TokenStoreClassName>org.wso2.carbon.identity.sts.store.DBTokenStore</TokenStoreClassName>\n\
            <XSSPreventionConfig>\n\
                <Enabled>true</Enabled>\n\
                <Rule>allow</Rule>\n\
                <Patterns>\n\
                </Patterns>\n\
            </XSSPreventionConfig>\n\
        </Security>\n\
    <HideMenuItemIds>\n\
    <HideMenuItemId>claim_mgt_menu</HideMenuItemId>\n\
    <HideMenuItemId>identity_mgt_emailtemplate_menu</HideMenuItemId>\n\
    <HideMenuItemId>identity_security_questions_menu</HideMenuItemId>\n\
    </HideMenuItemIds>\n\
        <WorkDirectory>\${carbon.home}/tmp/work</WorkDirectory>\n\
        <HouseKeeping>\n\
            <AutoStart>true</AutoStart>\n\
            <Interval>10</Interval>\n\
            <MaxTempFileLifetime>30</MaxTempFileLifetime>\n\
        </HouseKeeping>\n\
        <FileUploadConfig>\n\
            <TotalFileSizeLimit>100</TotalFileSizeLimit>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>keystore</Action>\n\
                    <Action>certificate</Action>\n\
                    <Action>*</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.AnyFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>jarZip</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.JarZipUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>dbs</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.DBSFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>tools</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsFileUploadExecutor</Class>\n\
            </Mapping>\n\
            <Mapping>\n\
                <Actions>\n\
                    <Action>toolsAny</Action>\n\
                </Actions>\n\
                <Class>org.wso2.carbon.ui.transports.fileupload.ToolsAnyFileUploadExecutor</Class>\n\
            </Mapping>\n\
        </FileUploadConfig>\n\
        <HttpGetRequestProcessors>\n\
            <Processor>\n\
                <Item>info</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.InfoProcessor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>wsdl</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.Wsdl11Processor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>wsdl2</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.Wsdl20Processor</Class>\n\
            </Processor>\n\
            <Processor>\n\
                <Item>xsd</Item>\n\
                <Class>org.wso2.carbon.core.transports.util.XsdProcessor</Class>\n\
            </Processor>\n\
        </HttpGetRequestProcessors>\n\
        <DeploymentSynchronizer>\n\
            <Enabled>false</Enabled>\n\
            <AutoCommit>false</AutoCommit>\n\
            <AutoCheckout>true</AutoCheckout>\n\
            <RepositoryType>svn</RepositoryType>\n\
            <SvnUrl>http://svnrepo.example.com/repos/</SvnUrl>\n\
            <SvnUser>username</SvnUser>\n\
            <SvnPassword>password</SvnPassword>\n\
            <SvnUrlAppendTenantId>true</SvnUrlAppendTenantId>\n\
        </DeploymentSynchronizer>\n\
        <ServerInitializers>\n\
        </ServerInitializers>\n\
        <RequireCarbonServlet>\${require.carbon.servlet}</RequireCarbonServlet>\n\
        <StatisticsReporterDisabled>true</StatisticsReporterDisabled>\n\
        <FeatureRepository>\n\
    	    <RepositoryName>default repository</RepositoryName>\n\
    	    <RepositoryURL>http://product-dist.wso2.com/p2/carbon/releases/wilkes/</RepositoryURL>\n\
        </FeatureRepository>\n\
       <APIManagement>\n\
    	<Enabled>true</Enabled>\n\
    	<LoadAPIContextsInServerStartup>true</LoadAPIContextsInServerStartup>\n\
       </APIManagement>\n\
    </Server>\n\
kind: ConfigMap\n\
metadata:\n\
  name: identity-server-conf\n\
  namespace: wso2\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  bps-datasources.xml: |\n\
    <datasources-configuration xmlns:svns=\"http://org.wso2.securevault/configuration\">\n\
       <providers>\n\
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>\n\
        </providers>\n\
      <datasources>\n\
            <datasource>\n\
                <name>BPS_DS</name>\n\
                <description></description>\n\
                <jndiConfig>\n\
                    <name>bpsds</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:./repository/database/WSO2IS_BPS_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>100</maxActive>\n\
                        <maxWait>10000</maxWait>\n\
                        <maxIdle>20</maxIdle>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <useDataSourceFactory>false</useDataSourceFactory>\n\
    		            <defaultAutoCommit>true</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
        </datasources>\n\
    </datasources-configuration>\n\
  master-datasources.xml: |\n\
    <datasources-configuration xmlns:svns=\"http://org.wso2.securevault/configuration\">\n\
        <providers>\n\
            <provider>org.wso2.carbon.ndatasource.rdbms.RDBMSDataSourceReader</provider>\n\
        </providers>\n\
        <datasources>\n\
            <datasource>\n\
                <name>WSO2_CARBON_DB</name>\n\
                <description>The datasource used for registry and user manager</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2CarbonDB</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:./repository/database/WSO2CARBON_DB;DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=60000</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2_USER_DB</name>\n\
                <description>The data source used for user management and user store</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2UserDS</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:mysql://wso2is-rdbms-service:3306/WSO2IS_USER_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>\n\
                        <maxActive>80</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <minIdle>5</minIdle>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2_CONFIG_REG_DB</name>\n\
                <description>The data source used for config registry</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2ConfigDS</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:./repository/database/WSO2IS_REG_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>50</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2_IDENTITY_DB</name>\n\
                <description>The data source used for identity</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2IdentityDS</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:mysql://wso2is-rdbms-service:3306/WSO2IS_IDENTITY_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>com.mysql.jdbc.Driver</driverClassName>\n\
                        <maxActive>80</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <minIdle>5</minIdle>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
            <datasource>\n\
                <name>WSO2_CONSENT_DB</name>\n\
                <description>The data source used for consent management</description>\n\
                <jndiConfig>\n\
                    <name>jdbc/WSO2ConsentDS</name>\n\
                </jndiConfig>\n\
                <definition type=\"RDBMS\">\n\
                    <configuration>\n\
                        <url>jdbc:h2:./repository/database/WSO2IS_CONSENT_DB?autoReconnect=true&amp;useSSL=false</url>\n\
                        <username>wso2carbon</username>\n\
                        <password>wso2carbon</password>\n\
                        <driverClassName>org.h2.Driver</driverClassName>\n\
                        <maxActive>80</maxActive>\n\
                        <maxWait>60000</maxWait>\n\
                        <minIdle>5</minIdle>\n\
                        <testOnBorrow>true</testOnBorrow>\n\
                        <validationQuery>SELECT 1</validationQuery>\n\
                        <validationInterval>30000</validationInterval>\n\
                        <defaultAutoCommit>false</defaultAutoCommit>\n\
                    </configuration>\n\
                </definition>\n\
            </datasource>\n\
       </datasources>\n\
    </datasources-configuration>\n\
kind: ConfigMap\n\
metadata:\n\
  name: identity-server-conf-datasources\n\
  namespace: wso2\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
data:\n\
  init.sql: |\n\
    DROP DATABASE IF EXISTS WSO2IS_USER_DB;\n\
    DROP DATABASE IF EXISTS WSO2IS_IDENTITY_DB;\n\
    DROP DATABASE IF EXISTS IS_ANALYTICS_DB;\n\
    CREATE DATABASE WSO2IS_USER_DB;\n\
    CREATE DATABASE WSO2IS_IDENTITY_DB;\n\
    CREATE DATABASE IS_ANALYTICS_DB;\n\
    CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON WSO2IS_USER_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON WSO2IS_IDENTITY_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    GRANT ALL ON IS_ANALYTICS_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';\n\
    USE WSO2IS_USER_DB;\n\
    CREATE TABLE UM_TENANT (\n\
    			UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	        UM_DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                UM_EMAIL VARCHAR(255),\n\
                UM_ACTIVE BOOLEAN DEFAULT FALSE,\n\
    	        UM_CREATED_DATE TIMESTAMP NOT NULL,\n\
    	        UM_USER_CONFIG LONGBLOB,\n\
    			PRIMARY KEY (UM_ID),\n\
    			UNIQUE(UM_DOMAIN_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_DOMAIN(\n\
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DOMAIN_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME\n\
                        ON UM_TENANT (UM_DOMAIN_NAME);\n\
    CREATE TABLE UM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE(\n\
    	UM_ID INTEGER  NOT NULL AUTO_INCREMENT,\n\
    	UM_MODULE_NAME VARCHAR(100),\n\
    	UNIQUE(UM_MODULE_NAME),\n\
    	PRIMARY KEY(UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE_ACTIONS(\n\
    	UM_ACTION VARCHAR(255) NOT NULL,\n\
    	UM_MODULE_ID INTEGER NOT NULL,\n\
    	PRIMARY KEY(UM_ACTION, UM_MODULE_ID),\n\
    	FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,\n\
                 UM_ACTION VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_MODULE_ID INTEGER DEFAULT 0,\n\
    			       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);\n\
    CREATE TABLE UM_ROLE_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	     UM_DOMAIN_ID INTEGER,\n\
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),\n\
    	     FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	     FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_ID INTEGER NOT NULL,\n\
                 UM_USER_ID INTEGER NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SHARED_USER_ROLE(\n\
        UM_ROLE_ID INTEGER NOT NULL,\n\
        UM_USER_ID INTEGER NOT NULL,\n\
        UM_USER_TENANT_ID INTEGER NOT NULL,\n\
        UM_ROLE_TENANT_ID INTEGER NOT NULL,\n\
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),\n\
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,\n\
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ACCOUNT_MAPPING(\n\
    	UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    	UM_TENANT_ID INTEGER NOT NULL,\n\
    	UM_USER_STORE_DOMAIN VARCHAR(100),\n\
    	UM_ACC_LINK_ID INTEGER NOT NULL,\n\
    	UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),\n\
    	FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,\n\
    	PRIMARY KEY (UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_ATTRIBUTE (\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ATTR_NAME VARCHAR(255) NOT NULL,\n\
                UM_ATTR_VALUE VARCHAR(1024),\n\
                UM_PROFILE_ID VARCHAR(255),\n\
                UM_USER_ID INTEGER,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);\n\
    CREATE TABLE UM_DIALECT(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_URI VARCHAR(255) NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_CLAIM(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_CLAIM_URI VARCHAR(255) NOT NULL,\n\
                UM_DISPLAY_TAG VARCHAR(255),\n\
                UM_DESCRIPTION VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE VARCHAR(255),\n\
                UM_REG_EX VARCHAR(255),\n\
                UM_SUPPORTED SMALLINT,\n\
                UM_REQUIRED SMALLINT,\n\
                UM_DISPLAY_ORDER INTEGER,\n\
    	    UM_CHECKED_ATTRIBUTE SMALLINT,\n\
                UM_READ_ONLY SMALLINT,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PROFILE_CONFIG(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_PROFILE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(\n\
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
        UM_PROFILE_ID INTEGER,\n\
        UM_CLAIM_ID INTEGER,\n\
        UM_BEHAVIOUR SMALLINT,\n\
        UM_TENANT_ID INTEGER DEFAULT 0,\n\
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),\n\
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),\n\
        PRIMARY KEY(UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	    UM_DOMAIN_ID INTEGER,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	    FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);\n\
    CREATE TABLE UM_SYSTEM_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_REMEMBER_ME(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    			UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    			UM_COOKIE_VALUE VARCHAR(1024),\n\
    			UM_CREATED_TIME TIMESTAMP,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    			PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    USE WSO2IS_IDENTITY_DB;\n\
    CREATE TABLE UM_TENANT (\n\
    			UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	        UM_DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                UM_EMAIL VARCHAR(255),\n\
                UM_ACTIVE BOOLEAN DEFAULT FALSE,\n\
    	        UM_CREATED_DATE TIMESTAMP NOT NULL,\n\
    	        UM_USER_CONFIG LONGBLOB,\n\
    			PRIMARY KEY (UM_ID),\n\
    			UNIQUE(UM_DOMAIN_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_DOMAIN(\n\
                UM_DOMAIN_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DOMAIN_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_DOMAIN_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE UNIQUE INDEX INDEX_UM_TENANT_UM_DOMAIN_NAME\n\
                        ON UM_TENANT (UM_DOMAIN_NAME);\n\
    CREATE TABLE UM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_USER (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_USER_PASSWORD VARCHAR(255) NOT NULL,\n\
                 UM_SALT_VALUE VARCHAR(31),\n\
                 UM_REQUIRE_CHANGE BOOLEAN DEFAULT FALSE,\n\
                 UM_CHANGED_TIME TIMESTAMP NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_USER_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_SHARED_ROLE BOOLEAN DEFAULT FALSE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID),\n\
                 UNIQUE(UM_ROLE_NAME, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE(\n\
    	UM_ID INTEGER  NOT NULL AUTO_INCREMENT,\n\
    	UM_MODULE_NAME VARCHAR(100),\n\
    	UNIQUE(UM_MODULE_NAME),\n\
    	PRIMARY KEY(UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_MODULE_ACTIONS(\n\
    	UM_ACTION VARCHAR(255) NOT NULL,\n\
    	UM_MODULE_ID INTEGER NOT NULL,\n\
    	PRIMARY KEY(UM_ACTION, UM_MODULE_ID),\n\
    	FOREIGN KEY (UM_MODULE_ID) REFERENCES UM_MODULE(UM_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_RESOURCE_ID VARCHAR(255) NOT NULL,\n\
                 UM_ACTION VARCHAR(255) NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    		UM_MODULE_ID INTEGER DEFAULT 0,\n\
    			       UNIQUE(UM_RESOURCE_ID,UM_ACTION, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX INDEX_UM_PERMISSION_UM_RESOURCE_ID_UM_ACTION ON UM_PERMISSION (UM_RESOURCE_ID, UM_ACTION, UM_TENANT_ID);\n\
    CREATE TABLE UM_ROLE_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_ROLE_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	     UM_DOMAIN_ID INTEGER,\n\
                 UNIQUE (UM_PERMISSION_ID, UM_ROLE_NAME, UM_TENANT_ID, UM_DOMAIN_ID),\n\
    	     FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	     FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_PERMISSION (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_PERMISSION_ID INTEGER NOT NULL,\n\
                 UM_USER_NAME VARCHAR(255) NOT NULL,\n\
                 UM_IS_ALLOWED SMALLINT NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 FOREIGN KEY (UM_PERMISSION_ID, UM_TENANT_ID) REFERENCES UM_PERMISSION(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_ROLE (\n\
                 UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 UM_ROLE_ID INTEGER NOT NULL,\n\
                 UM_USER_ID INTEGER NOT NULL,\n\
                 UM_TENANT_ID INTEGER DEFAULT 0,\n\
                 UNIQUE (UM_USER_ID, UM_ROLE_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_ROLE(UM_ID, UM_TENANT_ID),\n\
                 FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                 PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SHARED_USER_ROLE(\n\
        UM_ROLE_ID INTEGER NOT NULL,\n\
        UM_USER_ID INTEGER NOT NULL,\n\
        UM_USER_TENANT_ID INTEGER NOT NULL,\n\
        UM_ROLE_TENANT_ID INTEGER NOT NULL,\n\
        UNIQUE(UM_USER_ID,UM_ROLE_ID,UM_USER_TENANT_ID, UM_ROLE_TENANT_ID),\n\
        FOREIGN KEY(UM_ROLE_ID,UM_ROLE_TENANT_ID) REFERENCES UM_ROLE(UM_ID,UM_TENANT_ID) ON DELETE CASCADE,\n\
        FOREIGN KEY(UM_USER_ID,UM_USER_TENANT_ID) REFERENCES UM_USER(UM_ID,UM_TENANT_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_ACCOUNT_MAPPING(\n\
    	UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    	UM_TENANT_ID INTEGER NOT NULL,\n\
    	UM_USER_STORE_DOMAIN VARCHAR(100),\n\
    	UM_ACC_LINK_ID INTEGER NOT NULL,\n\
    	UNIQUE(UM_USER_NAME, UM_TENANT_ID, UM_USER_STORE_DOMAIN, UM_ACC_LINK_ID),\n\
    	FOREIGN KEY (UM_TENANT_ID) REFERENCES UM_TENANT(UM_ID) ON DELETE CASCADE,\n\
    	PRIMARY KEY (UM_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_USER_ATTRIBUTE (\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ATTR_NAME VARCHAR(255) NOT NULL,\n\
                UM_ATTR_VALUE VARCHAR(1024),\n\
                UM_PROFILE_ID VARCHAR(255),\n\
                UM_USER_ID INTEGER,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY (UM_USER_ID, UM_TENANT_ID) REFERENCES UM_USER(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX UM_USER_ID_INDEX ON UM_USER_ATTRIBUTE(UM_USER_ID);\n\
    CREATE TABLE UM_DIALECT(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_URI VARCHAR(255) NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_URI, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_CLAIM(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_CLAIM_URI VARCHAR(255) NOT NULL,\n\
                UM_DISPLAY_TAG VARCHAR(255),\n\
                UM_DESCRIPTION VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE_DOMAIN VARCHAR(255),\n\
                UM_MAPPED_ATTRIBUTE VARCHAR(255),\n\
                UM_REG_EX VARCHAR(255),\n\
                UM_SUPPORTED SMALLINT,\n\
                UM_REQUIRED SMALLINT,\n\
                UM_DISPLAY_ORDER INTEGER,\n\
    	    UM_CHECKED_ATTRIBUTE SMALLINT,\n\
                UM_READ_ONLY SMALLINT,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE(UM_DIALECT_ID, UM_CLAIM_URI, UM_TENANT_ID,UM_MAPPED_ATTRIBUTE_DOMAIN),\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_PROFILE_CONFIG(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_DIALECT_ID INTEGER NOT NULL,\n\
                UM_PROFILE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                FOREIGN KEY(UM_DIALECT_ID, UM_TENANT_ID) REFERENCES UM_DIALECT(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS UM_CLAIM_BEHAVIOR(\n\
        UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
        UM_PROFILE_ID INTEGER,\n\
        UM_CLAIM_ID INTEGER,\n\
        UM_BEHAVIOUR SMALLINT,\n\
        UM_TENANT_ID INTEGER DEFAULT 0,\n\
        FOREIGN KEY(UM_PROFILE_ID, UM_TENANT_ID) REFERENCES UM_PROFILE_CONFIG(UM_ID,UM_TENANT_ID),\n\
        FOREIGN KEY(UM_CLAIM_ID, UM_TENANT_ID) REFERENCES UM_CLAIM(UM_ID,UM_TENANT_ID),\n\
        PRIMARY KEY(UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    	    UM_DOMAIN_ID INTEGER,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID, UM_DOMAIN_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_HYBRID_ROLE(UM_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
    	    FOREIGN KEY (UM_DOMAIN_ID, UM_TENANT_ID) REFERENCES UM_DOMAIN(UM_DOMAIN_ID, UM_TENANT_ID) ON DELETE CASCADE,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_SYSTEM_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_ROLE_NAME VARCHAR(255),\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX SYSTEM_ROLE_IND_BY_RN_TI ON UM_SYSTEM_ROLE(UM_ROLE_NAME, UM_TENANT_ID);\n\
    CREATE TABLE UM_SYSTEM_USER_ROLE(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                UM_USER_NAME VARCHAR(255),\n\
                UM_ROLE_ID INTEGER NOT NULL,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
                UNIQUE (UM_USER_NAME, UM_ROLE_ID, UM_TENANT_ID),\n\
                FOREIGN KEY (UM_ROLE_ID, UM_TENANT_ID) REFERENCES UM_SYSTEM_ROLE(UM_ID, UM_TENANT_ID),\n\
                PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE UM_HYBRID_REMEMBER_ME(\n\
                UM_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    			UM_USER_NAME VARCHAR(255) NOT NULL,\n\
    			UM_COOKIE_VALUE VARCHAR(1024),\n\
    			UM_CREATED_TIME TIMESTAMP,\n\
                UM_TENANT_ID INTEGER DEFAULT 0,\n\
    			PRIMARY KEY (UM_ID, UM_TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_BASE_TABLE (\n\
                PRODUCT_NAME VARCHAR(20),\n\
                PRIMARY KEY (PRODUCT_NAME)\n\
    )ENGINE INNODB;\n\
    INSERT INTO IDN_BASE_TABLE values ('WSO2 Identity Server');\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH_CONSUMER_APPS (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                CONSUMER_KEY VARCHAR(255),\n\
                CONSUMER_SECRET VARCHAR(2048),\n\
                USERNAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                USER_DOMAIN VARCHAR(50),\n\
                APP_NAME VARCHAR(255),\n\
                OAUTH_VERSION VARCHAR(128),\n\
                CALLBACK_URL VARCHAR(1024),\n\
                GRANT_TYPES VARCHAR (1024),\n\
                PKCE_MANDATORY CHAR(1) DEFAULT '0',\n\
                PKCE_SUPPORT_PLAIN CHAR(1) DEFAULT '0',\n\
                APP_STATE VARCHAR (25) DEFAULT 'ACTIVE',\n\
                USER_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                APP_ACCESS_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                REFRESH_TOKEN_EXPIRE_TIME BIGINT DEFAULT 84600,\n\
                ID_TOKEN_EXPIRE_TIME BIGINT DEFAULT 3600,\n\
                CONSTRAINT CONSUMER_KEY_CONSTRAINT UNIQUE (CONSUMER_KEY),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_VALIDATORS (\n\
    	APP_ID INTEGER NOT NULL,\n\
    	SCOPE_VALIDATOR VARCHAR (128) NOT NULL,\n\
    	PRIMARY KEY (APP_ID,SCOPE_VALIDATOR),\n\
    	FOREIGN KEY (APP_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_REQUEST_TOKEN (\n\
                REQUEST_TOKEN VARCHAR(255),\n\
                REQUEST_TOKEN_SECRET VARCHAR(512),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                CALLBACK_URL VARCHAR(1024),\n\
                SCOPE VARCHAR(2048),\n\
                AUTHORIZED VARCHAR(128),\n\
                OAUTH_VERIFIER VARCHAR(512),\n\
                AUTHZ_USER VARCHAR(512),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (REQUEST_TOKEN),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH1A_ACCESS_TOKEN (\n\
                ACCESS_TOKEN VARCHAR(255),\n\
                ACCESS_TOKEN_SECRET VARCHAR(512),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                SCOPE VARCHAR(2048),\n\
                AUTHZ_USER VARCHAR(512),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ACCESS_TOKEN),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN (\n\
                TOKEN_ID VARCHAR (255),\n\
                ACCESS_TOKEN VARCHAR(2048),\n\
                REFRESH_TOKEN VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                USER_TYPE VARCHAR (25),\n\
                GRANT_TYPE VARCHAR (50),\n\
                TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                VALIDITY_PERIOD BIGINT,\n\
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,\n\
                TOKEN_SCOPE_HASH VARCHAR(32),\n\
                TOKEN_STATE VARCHAR(25) DEFAULT 'ACTIVE',\n\
                TOKEN_STATE_ID VARCHAR (128) DEFAULT 'NONE',\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                ACCESS_TOKEN_HASH VARCHAR(512),\n\
                REFRESH_TOKEN_HASH VARCHAR(512),\n\
                PRIMARY KEY (TOKEN_ID),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,\n\
                CONSTRAINT CON_APP_KEY UNIQUE (CONSUMER_KEY_ID,AUTHZ_USER,TENANT_ID,USER_DOMAIN,USER_TYPE,TOKEN_SCOPE_HASH,\n\
                                               TOKEN_STATE,TOKEN_STATE_ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AT_CK_AU ON IDN_OAUTH2_ACCESS_TOKEN(CONSUMER_KEY_ID, AUTHZ_USER, TOKEN_STATE, USER_TYPE);\n\
    CREATE INDEX IDX_TC ON IDN_OAUTH2_ACCESS_TOKEN(TIME_CREATED);\n\
    CREATE INDEX IDX_ATH ON IDN_OAUTH2_ACCESS_TOKEN(ACCESS_TOKEN_HASH);\n\
    CREATE INDEX IDX_AT_TI_UD ON IDN_OAUTH2_ACCESS_TOKEN(AUTHZ_USER, TENANT_ID, TOKEN_STATE, USER_DOMAIN);\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_AUDIT (\n\
                TOKEN_ID VARCHAR (255),\n\
                ACCESS_TOKEN VARCHAR(2048),\n\
                REFRESH_TOKEN VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                USER_TYPE VARCHAR (25),\n\
                GRANT_TYPE VARCHAR (50),\n\
                TIME_CREATED TIMESTAMP NULL,\n\
                REFRESH_TOKEN_TIME_CREATED TIMESTAMP NULL,\n\
                VALIDITY_PERIOD BIGINT,\n\
                REFRESH_TOKEN_VALIDITY_PERIOD BIGINT,\n\
                TOKEN_SCOPE_HASH VARCHAR(32),\n\
                TOKEN_STATE VARCHAR(25),\n\
                TOKEN_STATE_ID VARCHAR (128) ,\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                ACCESS_TOKEN_HASH VARCHAR(512),\n\
                REFRESH_TOKEN_HASH VARCHAR(512),\n\
                INVALIDATED_TIME TIMESTAMP NULL\n\
    );\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_AUTHORIZATION_CODE (\n\
                CODE_ID VARCHAR (255),\n\
                AUTHORIZATION_CODE VARCHAR(2048),\n\
                CONSUMER_KEY_ID INTEGER,\n\
                CALLBACK_URL VARCHAR(1024),\n\
                SCOPE VARCHAR(2048),\n\
                AUTHZ_USER VARCHAR (100),\n\
                TENANT_ID INTEGER,\n\
                USER_DOMAIN VARCHAR(50),\n\
                TIME_CREATED TIMESTAMP,\n\
                VALIDITY_PERIOD BIGINT,\n\
                STATE VARCHAR (25) DEFAULT 'ACTIVE',\n\
                TOKEN_ID VARCHAR(255),\n\
                SUBJECT_IDENTIFIER VARCHAR(255),\n\
                PKCE_CODE_CHALLENGE VARCHAR(255),\n\
                PKCE_CODE_CHALLENGE_METHOD VARCHAR(128),\n\
                AUTHORIZATION_CODE_HASH VARCHAR(512),\n\
                PRIMARY KEY (CODE_ID),\n\
                FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AUTHORIZATION_CODE_HASH ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHORIZATION_CODE_HASH,CONSUMER_KEY_ID);\n\
    CREATE INDEX IDX_AUTHORIZATION_CODE_AU_TI ON IDN_OAUTH2_AUTHORIZATION_CODE (AUTHZ_USER,TENANT_ID, USER_DOMAIN, STATE);\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_ACCESS_TOKEN_SCOPE (\n\
                TOKEN_ID VARCHAR (255),\n\
                TOKEN_SCOPE VARCHAR (60),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (TOKEN_ID, TOKEN_SCOPE),\n\
                FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE (\n\
                SCOPE_ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255) NOT NULL,\n\
                DESCRIPTION VARCHAR(512),\n\
                TENANT_ID INTEGER NOT NULL DEFAULT -1,\n\
                PRIMARY KEY (SCOPE_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_SCOPE_BINDING (\n\
                SCOPE_ID INTEGER NOT NULL,\n\
                SCOPE_BINDING VARCHAR(255),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE(SCOPE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OAUTH2_RESOURCE_SCOPE (\n\
                RESOURCE_PATH VARCHAR(255) NOT NULL,\n\
                SCOPE_ID INTEGER NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (RESOURCE_PATH),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OAUTH2_SCOPE (SCOPE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_SCIM_GROUP (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                ROLE_NAME VARCHAR(255) NOT NULL,\n\
                ATTR_NAME VARCHAR(1024) NOT NULL,\n\
                ATTR_VALUE VARCHAR(1024),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME);\n\
    CREATE INDEX IDX_IDN_SCIM_GROUP_TI_RN_AN ON IDN_SCIM_GROUP (TENANT_ID, ROLE_NAME, ATTR_NAME);\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_REMEMBER_ME (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                COOKIE_VALUE VARCHAR(1024),\n\
                CREATED_TIME TIMESTAMP,\n\
                PRIMARY KEY (USER_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_USER_RPS (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT 0,\n\
                RP_URL VARCHAR(255) NOT NULL,\n\
                TRUSTED_ALWAYS VARCHAR(128) DEFAULT 'FALSE',\n\
                LAST_VISIT DATE NOT NULL,\n\
                VISIT_COUNT INTEGER DEFAULT 0,\n\
                DEFAULT_PROFILE_NAME VARCHAR(255) DEFAULT 'DEFAULT',\n\
                PRIMARY KEY (USER_NAME, TENANT_ID, RP_URL)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OPENID_ASSOCIATIONS (\n\
                HANDLE VARCHAR(255) NOT NULL,\n\
                ASSOC_TYPE VARCHAR(255) NOT NULL,\n\
                EXPIRE_IN TIMESTAMP NOT NULL,\n\
                MAC_KEY VARCHAR(255) NOT NULL,\n\
                ASSOC_STORE VARCHAR(128) DEFAULT 'SHARED',\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (HANDLE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_STS_STORE (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TOKEN_ID VARCHAR(255) NOT NULL,\n\
                TOKEN_CONTENT BLOB(1024) NOT NULL,\n\
                CREATE_DATE TIMESTAMP NOT NULL,\n\
                EXPIRE_DATE TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
                STATE INTEGER DEFAULT 0,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_USER_DATA (\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                DATA_KEY VARCHAR(255) NOT NULL,\n\
                DATA_VALUE VARCHAR(2048),\n\
                PRIMARY KEY (TENANT_ID, USER_NAME, DATA_KEY)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_IDENTITY_META_DATA (\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                METADATA_TYPE VARCHAR(255) NOT NULL,\n\
                METADATA VARCHAR(255) NOT NULL,\n\
                VALID VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, USER_NAME, METADATA_TYPE,METADATA)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_THRIFT_SESSION (\n\
                SESSION_ID VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                CREATED_TIME VARCHAR(255) NOT NULL,\n\
                LAST_MODIFIED_TIME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (SESSION_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_SESSION_STORE (\n\
                SESSION_ID VARCHAR (100) NOT NULL,\n\
                SESSION_TYPE VARCHAR(100) NOT NULL,\n\
                OPERATION VARCHAR(10) NOT NULL,\n\
                SESSION_OBJECT BLOB,\n\
                TIME_CREATED BIGINT,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                EXPIRY_TIME BIGINT,\n\
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_AUTH_SESSION_TIME ON IDN_AUTH_SESSION_STORE (TIME_CREATED);\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_TEMP_SESSION_STORE (\n\
                SESSION_ID VARCHAR (100) NOT NULL,\n\
                SESSION_TYPE VARCHAR(100) NOT NULL,\n\
                OPERATION VARCHAR(10) NOT NULL,\n\
                SESSION_OBJECT BLOB,\n\
                TIME_CREATED BIGINT,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                EXPIRY_TIME BIGINT,\n\
                PRIMARY KEY (SESSION_ID, SESSION_TYPE, TIME_CREATED, OPERATION)\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_IDN_AUTH_TMP_SESSION_TIME ON IDN_AUTH_TEMP_SESSION_STORE (TIME_CREATED);\n\
    CREATE TABLE IF NOT EXISTS SP_APP (\n\
            ID INTEGER NOT NULL AUTO_INCREMENT,\n\
            TENANT_ID INTEGER NOT NULL,\n\
    	    	APP_NAME VARCHAR (255) NOT NULL ,\n\
    	    	USER_STORE VARCHAR (255) NOT NULL,\n\
            USERNAME VARCHAR (255) NOT NULL ,\n\
            DESCRIPTION VARCHAR (1024),\n\
    	    	ROLE_CLAIM VARCHAR (512),\n\
            AUTH_TYPE VARCHAR (255) NOT NULL,\n\
    	    	PROVISIONING_USERSTORE_DOMAIN VARCHAR (512),\n\
    	    	IS_LOCAL_CLAIM_DIALECT CHAR(1) DEFAULT '1',\n\
    	    	IS_SEND_LOCAL_SUBJECT_ID CHAR(1) DEFAULT '0',\n\
    	    	IS_SEND_AUTH_LIST_OF_IDPS CHAR(1) DEFAULT '0',\n\
            IS_USE_TENANT_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',\n\
            IS_USE_USER_DOMAIN_SUBJECT CHAR(1) DEFAULT '1',\n\
            ENABLE_AUTHORIZATION CHAR(1) DEFAULT '0',\n\
    	    	SUBJECT_CLAIM_URI VARCHAR (512),\n\
    	    	IS_SAAS_APP CHAR(1) DEFAULT '0',\n\
    	    	IS_DUMB_MODE CHAR(1) DEFAULT '0',\n\
            PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_APP ADD CONSTRAINT APPLICATION_NAME_CONSTRAINT UNIQUE(APP_NAME, TENANT_ID);\n\
    CREATE TABLE IF NOT EXISTS SP_METADATA (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                SP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                VALUE VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID),\n\
                CONSTRAINT SP_METADATA_CONSTRAINT UNIQUE (SP_ID, NAME),\n\
                FOREIGN KEY (SP_ID) REFERENCES SP_APP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS SP_INBOUND_AUTH (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                INBOUND_AUTH_KEY VARCHAR (255),\n\
                INBOUND_AUTH_TYPE VARCHAR (255) NOT NULL,\n\
                INBOUND_CONFIG_TYPE VARCHAR (255) NOT NULL,\n\
                PROP_NAME VARCHAR (255),\n\
                PROP_VALUE VARCHAR (1024) ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_INBOUND_AUTH ADD CONSTRAINT APPLICATION_ID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_AUTH_STEP (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                STEP_ORDER INTEGER DEFAULT 1,\n\
                APP_ID INTEGER NOT NULL ,\n\
                IS_SUBJECT_STEP CHAR(1) DEFAULT '0',\n\
                IS_ATTRIBUTE_STEP CHAR(1) DEFAULT '0',\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_AUTH_STEP ADD CONSTRAINT APPLICATION_ID_CONSTRAINT_STEP FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_FEDERATED_IDP (\n\
                ID INTEGER NOT NULL,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                AUTHENTICATOR_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID, AUTHENTICATOR_ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_FEDERATED_IDP ADD CONSTRAINT STEP_ID_CONSTRAINT FOREIGN KEY (ID) REFERENCES SP_AUTH_STEP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_CLAIM_DIALECT (\n\
    	   	ID INTEGER NOT NULL AUTO_INCREMENT,\n\
    	   	TENANT_ID INTEGER NOT NULL,\n\
    	   	SP_DIALECT VARCHAR (512) NOT NULL,\n\
    	   	APP_ID INTEGER NOT NULL,\n\
    	   	PRIMARY KEY (ID));\n\
    ALTER TABLE SP_CLAIM_DIALECT ADD CONSTRAINT DIALECTID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_CLAIM_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_CLAIM VARCHAR (512) NOT NULL ,\n\
                SP_CLAIM VARCHAR (512) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
    	    IS_MANDATORY VARCHAR(128) DEFAULT '0',\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_CLAIM_MAPPING ADD CONSTRAINT CLAIMID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_ROLE_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_ROLE VARCHAR (255) NOT NULL ,\n\
                SP_ROLE VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_ROLE_MAPPING ADD CONSTRAINT ROLEID_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_REQ_PATH_AUTHENTICATOR (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                AUTHENTICATOR_NAME VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_REQ_PATH_AUTHENTICATOR ADD CONSTRAINT REQ_AUTH_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE IF NOT EXISTS SP_PROVISIONING_CONNECTOR (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                TENANT_ID INTEGER NOT NULL,\n\
                IDP_NAME VARCHAR (255) NOT NULL ,\n\
                CONNECTOR_NAME VARCHAR (255) NOT NULL ,\n\
                APP_ID INTEGER NOT NULL,\n\
                IS_JIT_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
                BLOCKING CHAR(1) NOT NULL DEFAULT '0',\n\
                RULE_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    ALTER TABLE SP_PROVISIONING_CONNECTOR ADD CONSTRAINT PRO_CONNECTOR_APPID_CONSTRAINT FOREIGN KEY (APP_ID) REFERENCES SP_APP (ID) ON DELETE CASCADE;\n\
    CREATE TABLE SP_AUTH_SCRIPT (\n\
      ID         INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID  INTEGER                NOT NULL,\n\
      APP_ID     INTEGER                NOT NULL,\n\
      TYPE       VARCHAR(255)           NOT NULL,\n\
      CONTENT    BLOB    DEFAULT NULL,\n\
      IS_ENABLED CHAR(1) NOT NULL DEFAULT '0',\n\
      PRIMARY KEY (ID));\n\
    CREATE TABLE IF NOT EXISTS SP_TEMPLATE (\n\
      ID         INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID  INTEGER                NOT NULL,\n\
      NAME VARCHAR(255) NOT NULL,\n\
      DESCRIPTION VARCHAR(1023),\n\
      CONTENT BLOB DEFAULT NULL,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT SP_TEMPLATE_CONSTRAINT UNIQUE (TENANT_ID, NAME));\n\
    CREATE INDEX IDX_SP_TEMPLATE ON SP_TEMPLATE (TENANT_ID, NAME);\n\
    CREATE TABLE IF NOT EXISTS IDN_AUTH_WAIT_STATUS (\n\
      ID              INTEGER AUTO_INCREMENT NOT NULL,\n\
      TENANT_ID       INTEGER                NOT NULL,\n\
      LONG_WAIT_KEY   VARCHAR(255)           NOT NULL,\n\
      WAIT_STATUS     CHAR(1) NOT NULL DEFAULT '1',\n\
      TIME_CREATED    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      EXPIRE_TIME     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT IDN_AUTH_WAIT_STATUS_KEY UNIQUE (LONG_WAIT_KEY));\n\
    CREATE TABLE IF NOT EXISTS IDP (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			TENANT_ID INTEGER,\n\
    			NAME VARCHAR(254) NOT NULL,\n\
    			IS_ENABLED CHAR(1) NOT NULL DEFAULT '1',\n\
    			IS_PRIMARY CHAR(1) NOT NULL DEFAULT '0',\n\
    			HOME_REALM_ID VARCHAR(254),\n\
    			IMAGE MEDIUMBLOB,\n\
    			CERTIFICATE BLOB,\n\
    			ALIAS VARCHAR(254),\n\
    			INBOUND_PROV_ENABLED CHAR (1) NOT NULL DEFAULT '0',\n\
    			INBOUND_PROV_USER_STORE_ID VARCHAR(254),\n\
     			USER_CLAIM_URI VARCHAR(254),\n\
     			ROLE_CLAIM_URI VARCHAR(254),\n\
      			DESCRIPTION VARCHAR (1024),\n\
     			DEFAULT_AUTHENTICATOR_NAME VARCHAR(254),\n\
     			DEFAULT_PRO_CONNECTOR_NAME VARCHAR(254),\n\
     			PROVISIONING_ROLE VARCHAR(128),\n\
     			IS_FEDERATION_HUB CHAR(1) NOT NULL DEFAULT '0',\n\
     			IS_LOCAL_CLAIM_DIALECT CHAR(1) NOT NULL DEFAULT '0',\n\
                DISPLAY_NAME VARCHAR(255),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (TENANT_ID, NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_ROLE (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			ROLE VARCHAR(254),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ID, ROLE),\n\
    			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_ROLE_MAPPING (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ROLE_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			USER_STORE_ID VARCHAR (253),\n\
    			LOCAL_ROLE VARCHAR(253),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ROLE_ID, TENANT_ID, USER_STORE_ID, LOCAL_ROLE),\n\
    			FOREIGN KEY (IDP_ROLE_ID) REFERENCES IDP_ROLE(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_CLAIM (\n\
    			ID INTEGER AUTO_INCREMENT,\n\
    			IDP_ID INTEGER,\n\
    			TENANT_ID INTEGER,\n\
    			CLAIM VARCHAR(254),\n\
    			PRIMARY KEY (ID),\n\
    			UNIQUE (IDP_ID, CLAIM),\n\
    			FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_CLAIM_MAPPING (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_CLAIM_ID INTEGER,\n\
                TENANT_ID INTEGER,\n\
                LOCAL_CLAIM VARCHAR(253),\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (IDP_CLAIM_ID, TENANT_ID, LOCAL_CLAIM),\n\
                FOREIGN KEY (IDP_CLAIM_ID) REFERENCES IDP_CLAIM(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                IS_ENABLED CHAR (1) DEFAULT '1',\n\
                DISPLAY_NAME VARCHAR(255),\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, NAME),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_METADATA (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_ID INTEGER,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                VALUE VARCHAR(255) NOT NULL,\n\
                DISPLAY_NAME VARCHAR(255),\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID),\n\
                CONSTRAINT IDP_METADATA_CONSTRAINT UNIQUE (IDP_ID, NAME),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_AUTHENTICATOR_PROPERTY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                AUTHENTICATOR_ID INTEGER,\n\
                PROPERTY_KEY VARCHAR(255) NOT NULL,\n\
                PROPERTY_VALUE VARCHAR(2047),\n\
                IS_SECRET CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, AUTHENTICATOR_ID, PROPERTY_KEY),\n\
                FOREIGN KEY (AUTHENTICATOR_ID) REFERENCES IDP_AUTHENTICATOR(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_CONFIG (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                PROVISIONING_CONNECTOR_TYPE VARCHAR(255) NOT NULL,\n\
                IS_ENABLED CHAR (1) DEFAULT '0',\n\
                IS_BLOCKING CHAR (1) DEFAULT '0',\n\
                IS_RULES_ENABLED CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, PROVISIONING_CONNECTOR_TYPE),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROV_CONFIG_PROPERTY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                PROVISIONING_CONFIG_ID INTEGER,\n\
                PROPERTY_KEY VARCHAR(255) NOT NULL,\n\
                PROPERTY_VALUE VARCHAR(2048),\n\
                PROPERTY_BLOB_VALUE BLOB,\n\
                PROPERTY_TYPE CHAR(32) NOT NULL,\n\
                IS_SECRET CHAR (1) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, PROVISIONING_CONFIG_ID, PROPERTY_KEY),\n\
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_PROVISIONING_ENTITY (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                PROVISIONING_CONFIG_ID INTEGER,\n\
                ENTITY_TYPE VARCHAR(255) NOT NULL,\n\
                ENTITY_LOCAL_USERSTORE VARCHAR(255) NOT NULL,\n\
                ENTITY_NAME VARCHAR(255) NOT NULL,\n\
                ENTITY_VALUE VARCHAR(255),\n\
                TENANT_ID INTEGER,\n\
                ENTITY_LOCAL_ID VARCHAR(255),\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (ENTITY_TYPE, TENANT_ID, ENTITY_LOCAL_USERSTORE, ENTITY_NAME, PROVISIONING_CONFIG_ID),\n\
                UNIQUE (PROVISIONING_CONFIG_ID, ENTITY_TYPE, ENTITY_VALUE),\n\
                FOREIGN KEY (PROVISIONING_CONFIG_ID) REFERENCES IDP_PROVISIONING_CONFIG(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDP_LOCAL_CLAIM (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                TENANT_ID INTEGER,\n\
                IDP_ID INTEGER,\n\
                CLAIM_URI VARCHAR(255) NOT NULL,\n\
                DEFAULT_VALUE VARCHAR(255),\n\
                IS_REQUESTED VARCHAR(128) DEFAULT '0',\n\
                PRIMARY KEY (ID),\n\
                UNIQUE (TENANT_ID, IDP_ID, CLAIM_URI),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_ASSOCIATED_ID (\n\
                ID INTEGER AUTO_INCREMENT,\n\
                IDP_USER_ID VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1234,\n\
                IDP_ID INTEGER NOT NULL,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (ID),\n\
                UNIQUE(IDP_USER_ID, TENANT_ID, IDP_ID),\n\
                FOREIGN KEY (IDP_ID) REFERENCES IDP(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_USER_ACCOUNT_ASSOCIATION (\n\
                ASSOCIATION_KEY VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(255) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS FIDO_DEVICE_STORE (\n\
                TENANT_ID INTEGER,\n\
                DOMAIN_NAME VARCHAR(255) NOT NULL,\n\
                USER_NAME VARCHAR(45) NOT NULL,\n\
                TIME_REGISTERED TIMESTAMP,\n\
                KEY_HANDLE VARCHAR(200) NOT NULL,\n\
                DEVICE_DATA VARCHAR(2048) NOT NULL,\n\
                PRIMARY KEY (TENANT_ID, DOMAIN_NAME, USER_NAME, KEY_HANDLE)\n\
            )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_REQUEST (\n\
        UUID VARCHAR (45),\n\
        CREATED_BY VARCHAR (255),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        OPERATION_TYPE VARCHAR (50),\n\
        CREATED_AT TIMESTAMP,\n\
        UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,\n\
        STATUS VARCHAR (30),\n\
        REQUEST BLOB,\n\
        PRIMARY KEY (UUID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_BPS_PROFILE (\n\
        PROFILE_NAME VARCHAR(45),\n\
        HOST_URL_MANAGER VARCHAR(255),\n\
        HOST_URL_WORKER VARCHAR(255),\n\
        USERNAME VARCHAR(45),\n\
        PASSWORD VARCHAR(1023),\n\
        CALLBACK_HOST VARCHAR (45),\n\
        CALLBACK_USERNAME VARCHAR (45),\n\
        CALLBACK_PASSWORD VARCHAR (255),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (PROFILE_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW(\n\
        ID VARCHAR (45),\n\
        WF_NAME VARCHAR (45),\n\
        DESCRIPTION VARCHAR (255),\n\
        TEMPLATE_ID VARCHAR (45),\n\
        IMPL_ID VARCHAR (45),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_ASSOCIATION(\n\
        ID INTEGER NOT NULL AUTO_INCREMENT,\n\
        ASSOC_NAME VARCHAR (45),\n\
        EVENT_ID VARCHAR(45),\n\
        ASSOC_CONDITION VARCHAR (2000),\n\
        WORKFLOW_ID VARCHAR (45),\n\
        IS_ENABLED CHAR (1) DEFAULT '1',\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY(ID),\n\
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_CONFIG_PARAM(\n\
        WORKFLOW_ID VARCHAR (45),\n\
        PARAM_NAME VARCHAR (45),\n\
        PARAM_VALUE VARCHAR (1000),\n\
        PARAM_QNAME VARCHAR (45),\n\
        PARAM_HOLDER VARCHAR (45),\n\
        TENANT_ID INTEGER DEFAULT -1,\n\
        PRIMARY KEY (WORKFLOW_ID, PARAM_NAME, PARAM_QNAME, PARAM_HOLDER),\n\
        FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_REQUEST_ENTITY_RELATIONSHIP(\n\
      REQUEST_ID VARCHAR (45),\n\
      ENTITY_NAME VARCHAR (255),\n\
      ENTITY_TYPE VARCHAR (50),\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      PRIMARY KEY(REQUEST_ID, ENTITY_NAME, ENTITY_TYPE, TENANT_ID),\n\
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS WF_WORKFLOW_REQUEST_RELATION(\n\
      RELATIONSHIP_ID VARCHAR (45),\n\
      WORKFLOW_ID VARCHAR (45),\n\
      REQUEST_ID VARCHAR (45),\n\
      UPDATED_AT TIMESTAMP,\n\
      STATUS VARCHAR (30),\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      PRIMARY KEY (RELATIONSHIP_ID),\n\
      FOREIGN KEY (WORKFLOW_ID) REFERENCES WF_WORKFLOW(ID)ON DELETE CASCADE,\n\
      FOREIGN KEY (REQUEST_ID) REFERENCES WF_REQUEST(UUID)ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_RECOVERY_DATA (\n\
      USER_NAME VARCHAR(255) NOT NULL,\n\
      USER_DOMAIN VARCHAR(127) NOT NULL,\n\
      TENANT_ID INTEGER DEFAULT -1,\n\
      CODE VARCHAR(255) NOT NULL,\n\
      SCENARIO VARCHAR(255) NOT NULL,\n\
      STEP VARCHAR(127) NOT NULL,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      REMAINING_SETS VARCHAR(2500) DEFAULT NULL,\n\
      PRIMARY KEY(USER_NAME, USER_DOMAIN, TENANT_ID, SCENARIO,STEP),\n\
      UNIQUE(CODE)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_PASSWORD_HISTORY_DATA (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      USER_NAME   VARCHAR(255) NOT NULL,\n\
      USER_DOMAIN VARCHAR(127) NOT NULL,\n\
      TENANT_ID   INTEGER DEFAULT -1,\n\
      SALT_VALUE  VARCHAR(255),\n\
      HASH        VARCHAR(255) NOT NULL,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      PRIMARY KEY(ID),\n\
      UNIQUE (USER_NAME,USER_DOMAIN,TENANT_ID,SALT_VALUE,HASH)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_DIALECT (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      DIALECT_URI VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      CONSTRAINT DIALECT_URI_CONSTRAINT UNIQUE (DIALECT_URI, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      DIALECT_ID INTEGER,\n\
      CLAIM_URI VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (DIALECT_ID) REFERENCES IDN_CLAIM_DIALECT(ID) ON DELETE CASCADE,\n\
      CONSTRAINT CLAIM_URI_CONSTRAINT UNIQUE (DIALECT_ID, CLAIM_URI, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPED_ATTRIBUTE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      LOCAL_CLAIM_ID INTEGER,\n\
      USER_STORE_DOMAIN_NAME VARCHAR (255) NOT NULL,\n\
      ATTRIBUTE_NAME VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT USER_STORE_DOMAIN_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, USER_STORE_DOMAIN_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_PROPERTY (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      LOCAL_CLAIM_ID INTEGER,\n\
      PROPERTY_NAME VARCHAR (255) NOT NULL,\n\
      PROPERTY_VALUE VARCHAR (255) NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT PROPERTY_NAME_CONSTRAINT UNIQUE (LOCAL_CLAIM_ID, PROPERTY_NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CLAIM_MAPPING (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      EXT_CLAIM_ID INTEGER NOT NULL,\n\
      MAPPED_LOCAL_CLAIM_ID INTEGER NOT NULL,\n\
      TENANT_ID INTEGER NOT NULL,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (EXT_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (MAPPED_LOCAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE,\n\
      CONSTRAINT EXT_TO_LOC_MAPPING_CONSTRN UNIQUE (EXT_CLAIM_ID, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS  IDN_SAML2_ASSERTION_STORE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      SAML2_ID  VARCHAR(255) ,\n\
      SAML2_ISSUER  VARCHAR(255) ,\n\
      SAML2_SUBJECT  VARCHAR(255) ,\n\
      SAML2_SESSION_INDEX  VARCHAR(255) ,\n\
      SAML2_AUTHN_CONTEXT_CLASS_REF  VARCHAR(255) ,\n\
      SAML2_ASSERTION  VARCHAR(4096) ,\n\
      PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IDN_SAML2_ARTIFACT_STORE (\n\
      ID INT(11) NOT NULL AUTO_INCREMENT,\n\
      SOURCE_ID VARCHAR(255) NOT NULL,\n\
      MESSAGE_HANDLER VARCHAR(255) NOT NULL,\n\
      AUTHN_REQ_DTO BLOB NOT NULL,\n\
      SESSION_ID VARCHAR(255) NOT NULL,\n\
      EXP_TIMESTAMP TIMESTAMP NOT NULL,\n\
      INIT_TIMESTAMP TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,\n\
      ASSERTION_ID VARCHAR(255),\n\
      PRIMARY KEY (\`ID\`)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_JTI (\n\
      JWT_ID VARCHAR(255) NOT NULL,\n\
      EXP_TIME TIMESTAMP NOT NULL ,\n\
      TIME_CREATED TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,\n\
      PRIMARY KEY (JWT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS  IDN_OIDC_PROPERTY (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      TENANT_ID  INTEGER,\n\
      CONSUMER_KEY  VARCHAR(255) ,\n\
      PROPERTY_KEY  VARCHAR(255) NOT NULL,\n\
      PROPERTY_VALUE  VARCHAR(2047) ,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (CONSUMER_KEY) REFERENCES IDN_OAUTH_CONSUMER_APPS(CONSUMER_KEY) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_REFERENCE (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      CONSUMER_KEY_ID INTEGER ,\n\
      CODE_ID VARCHAR(255) ,\n\
      TOKEN_ID VARCHAR(255) ,\n\
      SESSION_DATA_KEY VARCHAR(255),\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (CONSUMER_KEY_ID) REFERENCES IDN_OAUTH_CONSUMER_APPS(ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (TOKEN_ID) REFERENCES IDN_OAUTH2_ACCESS_TOKEN(TOKEN_ID) ON DELETE CASCADE,\n\
      FOREIGN KEY (CODE_ID) REFERENCES IDN_OAUTH2_AUTHORIZATION_CODE(CODE_ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJECT_CLAIMS (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      REQ_OBJECT_ID INTEGER,\n\
      CLAIM_ATTRIBUTE VARCHAR(255) ,\n\
      ESSENTIAL CHAR(1) NOT NULL DEFAULT '0' ,\n\
      VALUE VARCHAR(255) ,\n\
      IS_USERINFO CHAR(1) NOT NULL DEFAULT '0',\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (REQ_OBJECT_ID) REFERENCES IDN_OIDC_REQ_OBJECT_REFERENCE (ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_REQ_OBJ_CLAIM_VALUES (\n\
      ID INTEGER NOT NULL AUTO_INCREMENT,\n\
      REQ_OBJECT_CLAIMS_ID INTEGER ,\n\
      CLAIM_VALUES VARCHAR(255) ,\n\
      PRIMARY KEY (ID),\n\
      FOREIGN KEY (REQ_OBJECT_CLAIMS_ID) REFERENCES  IDN_OIDC_REQ_OBJECT_CLAIMS(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_CERTIFICATE (\n\
                 ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                 NAME VARCHAR(100),\n\
                 CERTIFICATE_IN_PEM BLOB,\n\
                 TENANT_ID INTEGER DEFAULT 0,\n\
                 PRIMARY KEY(ID),\n\
                 CONSTRAINT CERTIFICATE_UNIQUE_KEY UNIQUE (NAME, TENANT_ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                NAME VARCHAR(255) NOT NULL,\n\
                TENANT_ID INTEGER DEFAULT -1,\n\
                PRIMARY KEY (ID)\n\
    )ENGINE INNODB;\n\
    CREATE TABLE IF NOT EXISTS IDN_OIDC_SCOPE_CLAIM_MAPPING (\n\
                ID INTEGER NOT NULL AUTO_INCREMENT,\n\
                SCOPE_ID INTEGER,\n\
                EXTERNAL_CLAIM_ID INTEGER,\n\
                PRIMARY KEY (ID),\n\
                FOREIGN KEY (SCOPE_ID) REFERENCES IDN_OIDC_SCOPE(ID) ON DELETE CASCADE,\n\
                FOREIGN KEY (EXTERNAL_CLAIM_ID) REFERENCES IDN_CLAIM(ID) ON DELETE CASCADE\n\
    )ENGINE INNODB;\n\
    CREATE INDEX IDX_AT_SI_ECI ON IDN_OIDC_SCOPE_CLAIM_MAPPING(SCOPE_ID, EXTERNAL_CLAIM_ID);\n\
kind: ConfigMap\n\
metadata:\n\
  name: mysql-dbscripts\n\
  namespace: wso2\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
kind: Service\n\
metadata:\n\
  name: wso2is-rdbms-service\n\
  namespace: wso2\n\
spec:\n\
  type: ClusterIP\n\
  selector:\n\
    deployment: wso2is-mysql\n\
  ports:\n\
    - name: mysql-port\n\
      port: 3306\n\
      targetPort: 3306\n\
      protocol: TCP\n\
---\n" >> deployment.yaml

echo -e "apiVersion: v1\n\
kind: Service\n\
metadata:\n\
  name: wso2is-is-service\n\
  namespace: wso2\n\
  labels:\n\
    deployment: wso2is-is\n\
spec:\n\
  selector:\n\
    deployment: wso2is-is\n\
  type: NodePort\n\
  ports:\n\
    - name: servlet-http\n\
      port: 9763\n\
      targetPort: 9763\n\
      protocol: TCP\n\
    - name: servlet-https\n\
      port: 9443\n\
      targetPort: 9443\n\
      protocol: TCP\n\
      nodePort: 30597\n\
---\n" >> deployment.yaml

echo -e "apiVersion: apps/v1\n\
kind: Deployment\n\
metadata:\n\
  name: wso2is-mysql-deployment\n\
  namespace: wso2\n\
spec:\n\
  replicas: 1\n\
  selector:\n\
    matchLabels:\n\
      deployment: wso2is-mysql\n\
  template:\n\
    metadata:\n\
      labels:\n\
        deployment: wso2is-mysql\n\
    spec:\n\
      containers:\n\
        - name: wso2is-mysql\n\
          image: mysql:5.7\n\
          livenessProbe:\n\
            exec:\n\
              command:\n\
                - sh\n\
                - -c\n\
                - \"mysqladmin ping -u root -p\${MYSQL_ROOT_PASSWORD}\"\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          readinessProbe:\n\
            exec:\n\
              command:\n\
                - sh\n\
                - -c\n\
                - \"mysqladmin ping -u root -p\${MYSQL_ROOT_PASSWORD}\"\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          imagePullPolicy: IfNotPresent\n\
          securityContext:\n\
            runAsUser: 999\n\
          env:\n\
            - name: MYSQL_ROOT_PASSWORD\n\
              value: root\n\
            - name: MYSQL_USER\n\
              value: wso2carbon\n\
            - name: MYSQL_PASSWORD\n\
              value: wso2carbon\n\
          ports:\n\
            - containerPort: 3306\n\
              protocol: TCP\n\
          volumeMounts:\n\
            - name: mysql-dbscripts\n\
              mountPath: /docker-entrypoint-initdb.d\n\
          args: [\"--max-connections\", \"10000\"]\n\
      volumes:\n\
        - name: mysql-dbscripts\n\
          configMap:\n\
            name: mysql-dbscripts\n\
      serviceAccountName: \"wso2svc-account\"\n\
---\n" >> deployment.yaml

echo -e "apiVersion: apps/v1\n\
kind: Deployment\n\
metadata:\n\
  name: wso2is-is-deployment\n\
  namespace: wso2\n\
spec:\n\
  replicas: 1\n\
  minReadySeconds: 30\n\
  strategy:\n\
    rollingUpdate:\n\
      maxSurge: 1\n\
      maxUnavailable: 0\n\
    type: RollingUpdate\n\
  selector:\n\
    matchLabels:\n\
      deployment: wso2is-is\n\
  template:\n\
    metadata:\n\
      labels:\n\
        deployment: wso2is-is\n\
    spec:\n\
      hostAliases:\n\
        - ip: \"127.0.0.1\"\n\
          hostnames:\n\
            - \"wso2is\"\n\
      containers:\n\
        - name: wso2is-is\n\
          image: docker.wso2.com/wso2is:5.7.0\n\
          livenessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/sh\n\
                - -c\n\
                - nc -z localhost 9443\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          readinessProbe:\n\
            exec:\n\
              command:\n\
                - /bin/sh\n\
                - -c\n\
                - nc -z localhost 9443\n\
            initialDelaySeconds: 60\n\
            periodSeconds: 10\n\
          lifecycle:\n\
            preStop:\n\
              exec:\n\
                command:  ['sh', '-c', '\${WSO2_SERVER_HOME}/bin/wso2server.sh stop']\n\
          imagePullPolicy: Always\n\
          securityContext:\n\
            runAsUser: 802\n\
          ports:\n\
            - containerPort: 9763\n\
              protocol: TCP\n\
            - containerPort: 9443\n\
              protocol: TCP\n\
          volumeMounts:\n\
            - name: identity-server-conf\n\
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf\n\
            - name: identity-server-conf-datasources\n\
              mountPath: /home/wso2carbon/wso2-config-volume/repository/conf/datasources\n\
      initContainers:\n\
        - name: init-is\n\
          image: busybox\n\
          command: ['sh', '-c', 'echo -e \"checking for the availability of MySQL\"; while ! nc -z wso2is-rdbms-service 3306; do sleep 1; printf \"-\"; done; echo -e \"  >> MySQL started\";']\n\
      serviceAccountName: \"wso2svc-account\"\n\
      imagePullSecrets:\n\
        - name: wso2creds\n\
      volumes:\n\
        - name: identity-server-conf\n\
          configMap:\n\
            name: identity-server-conf\n\
        - name: identity-server-conf-datasources\n\
          configMap:\n\
            name: identity-server-conf-datasources\n\
---\n" >> deployment.yaml

echoBold "1. Run kubectl create -f deployment.yaml on your terminal"
echoBold "2. Try navigating to https://<NODE-IP>:30597/carbon/ from your favourite browser"