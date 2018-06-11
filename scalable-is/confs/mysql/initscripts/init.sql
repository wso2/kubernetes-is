--
-- Copyright 2017 WSO2 Inc. (http://wso2.org)
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

DROP DATABASE IF EXISTS WSO2_USER_DB;
DROP DATABASE IF EXISTS WSO2_IDENTITY_DB;
DROP DATABASE IF EXISTS WSO2_REG_DB;
DROP DATABASE IF EXISTS WSO2_BPS_DB;
DROP DATABASE IF EXISTS WSO2_CONSENT_DB;

CREATE DATABASE WSO2_USER_DB;
CREATE DATABASE WSO2_IDENTITY_DB;
CREATE DATABASE WSO2_REG_DB;
CREATE DATABASE WSO2_BPS_DB;
CREATE DATABASE WSO2_CONSENT_DB;

CREATE USER IF NOT EXISTS 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';

GRANT ALL ON WSO2_USER_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
GRANT ALL ON WSO2_IDENTITY_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
GRANT ALL ON WSO2_REG_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
GRANT ALL ON WSO2_BPS_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';
GRANT ALL ON WSO2_CONSENT_DB.* TO 'wso2carbon'@'%' IDENTIFIED BY 'wso2carbon';

USE WSO2_USER_DB;
SOURCE /home/wso2is-5.5.0-db-scripts/user-mgt.sql;

USE WSO2_IDENTITY_DB;
SOURCE /home/wso2is-5.5.0-db-scripts/identity.sql;

USE WSO2_REG_DB;
SOURCE /home/wso2is-5.5.0-db-scripts/registry.sql;

USE WSO2_BPS_DB;
SOURCE /home/wso2is-5.5.0-db-scripts/bps.sql;

USE WSO2_CONSENT_DB;
SOURCE /home/wso2is-5.5.0-db-scripts/consent.sql;