# Building docker images

##### 1. Build the docker image for IS:

###### Download files required

- wso2is-5.4.0.zip
- jdk-8u*-linux-x64.tar.gz (Any JDK 8u* version)
- dnsjava-2.1.8.jar (http://www.dnsjava.org/)
- [`kubernetes-membership-scheme-1.0.1.jar`](https://github.com/wso2/kubernetes-common/releases/tag/v1.0.1)
- mysql-connector-java-5*-bin.jar (Any mysql connector 5* version)

###### Add above files to is/files directory.
###### Build the docker image from is/ directory.
```
docker build -t docker.wso2.com/wso2is-kubernetes:5.4.0 .
```

##### 2. Build the docker image for MySQL:

> mysql docker image does not need any additional files to be added.

###### Build the docker image from mysql/ directory.
```
docker build -t docker.wso2.com/wso2is-mysql-kubernetes:5.7 .
```