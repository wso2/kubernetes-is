# Building docker images

##### 1. Build the docker image for IS:

###### Download files required

- wso2is-5.4.1.zip
- jdk-8u*-linux-x64.tar.gz (Any JDK 8u* version)
- dnsjava-2.1.8.jar (http://www.dnsjava.org/)
- [`kubernetes-membership-scheme-1.0.1.jar`](https://github.com/wso2/kubernetes-common/releases/tag/v1.0.1)
- mysql-connector-java-5*-bin.jar (Any mysql connector 5* version)

Tested against jdk-8u45-linux-x64.tar.gz and mysql-connector-java-5.1.46-bin.jar

###### Add above files to is/files directory.
###### Build the docker image from is/ directory.
```
docker build -t docker.wso2.com/wso2is-kubernetes:5.4.1 .
```