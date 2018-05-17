# Building docker images

#### Prerequisites
* [Docker](https://www.docker.com/get-docker) v17.09.0 or above

>The local copy of the `dockerfiles/is` directory will be referred to as `IS_DOCKERFILE_HOME` from this point onwards.

#### Add JDK, WSO2 Identity Server distribution, MySQL connector, Kubernetes member scheme, DNS Java to `<IS_DOCKERFILE_HOME>/files`

- Download [JDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
and extract it to `<IS_DOCKERFILE_HOME>/files`.
- Download the WSO2 Identity Server 5.5.0 distribution (https://wso2.com/identity-and-access-management)
and extract it to `<IS_DOCKERFILE_HOME>/files`. <br>
- Once both JDK and WSO2 Identity Server distributions are extracted it may look as follows:

  ```bash
  <IS_DOCKERFILE_HOME>/files/jdk<version>/
  <IS_DOCKERFILE_HOME>/files/wso2is-5.5.0/
  ```
- Download [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/) v5.1.* and then copy that to 
`<IS_DOCKERFILE_HOME>/files` folder
- Download [`kubernetes-membership-scheme-1.0.1.jar`](https://github.com/wso2/kubernetes-common/releases/tag/v1.0.1) 
and then copy that to `<IS_DOCKERFILE_HOME>/files`
- Download [`dnsjava-2.1.8.jar`](http://www.dnsjava.org/) and copy that to  `<IS_DOCKERFILE_HOME>/files`

#### Build the docker image from is/ directory.
```
docker build -t docker.cloud.wso2.com/wso2is-kubernetes:5.5.0 .
```