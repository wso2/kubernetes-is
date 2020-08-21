# Changelog

All notable changes to this project 5.10.x per each release will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v5.10.0.2] - 2020-08-21

### Environments

- Successful evaluation of IAM Helm chart in AWS Elastic Kubernetes Service (EKS) (refer to [issue](https://github.com/wso2/kubernetes-is/issues/250))
- Successful evaluation of Google Cloud Filestore as a Persistent Storage Solution (refer to [issue](https://github.com/wso2/kubernetes-is/issues/227))
- Successful evaluation of Ceph File System (CephFS) as a Persistent Storage Solution (refer to [issue](https://github.com/wso2/kubernetes-is/issues/240))

### Added

- Add user input option to set Identity service hostname (refer to [issue](https://github.com/wso2/kubernetes-is/issues/222))
- Add user input option to set desired Kubernetes StorageClass (refer to [issue](https://github.com/wso2/kubernetes-is/issues/228))
- Add user input option to set Ingress class and annotations (refer to [issue](https://github.com/wso2/kubernetes-is/issues/257))
- Integrate support For automatic rolling update upon ConfigMap changes (refer to [issue](https://github.com/wso2/kubernetes-is/issues/232))
- Test and document managing custom keystores and truststores (refer to [issue](https://github.com/wso2/kubernetes-is/issues/224))

### Changed

- Move Identity Server deployment from stateless to stateful (refer to [issue](https://github.com/wso2/kubernetes-is/issues/220))
- Avoid packaging NFS Server Provisioner with IAM Helm chart (refer to [issue](https://github.com/wso2/kubernetes-is/issues/242))
- Improve memory allocation for Identity Server (refer to [issue](https://github.com/wso2/kubernetes-is/issues/233))
- Include the WSO2 configuration file content within the Kubernetes ConfigMap (refer to [issue](https://github.com/wso2/kubernetes-is/issues/231))
- Upgrade the Base MySQL Helm Chart Version (refer to [issue](https://github.com/wso2/kubernetes-is/issues/260))
- Upgrade Logstash version (refer to [issue](https://github.com/wso2/kubernetes-is/issues/247))
- Add pattern name as a named template in IAM Helm chart (refer to [issue](https://github.com/wso2/kubernetes-is/issues/236))

### Fixed

- Fix SSLHandshakeException in membership scheme initialization with server version 1.16 (refer to [issue](https://github.com/wso2/kubernetes-is/issues/255))
- Fix formatting in IAM Helm chart `NOTES.txt` file (refer to [issue](https://github.com/wso2/kubernetes-is/issues/217))
- Verify Logstash default plugins (refer to [issue](https://github.com/wso2/kubernetes-is/issues/245))
- Fix incorrect file share path between Logstash sidecar container and IS (refer to [issue](https://github.com/wso2/kubernetes-is/issues/239))

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v5.10.0.2](https://github.com/wso2/kubernetes-is/milestone/9).

## [v5.10.0.1] - 2020-03-20

### Added

- Introduce Kubernetes resources for simplified deployment of WSO2 Identity Server version `5.10.0`
- Introduce Helm chart for WSO2 IAM version `5.10.0` deployment pattern 1

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v5.10.0.1](https://github.com/wso2/kubernetes-is/milestone/8).

[v5.10.0.2]: https://github.com/wso2/kubernetes-is/compare/v5.10.0.1...v5.10.0.2
[v5.10.0.1]: https://github.com/wso2/kubernetes-is/compare/v5.9.0.1...v5.10.0.1
