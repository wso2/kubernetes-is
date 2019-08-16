# Changelog
All notable changes to this project 5.8.x per each release will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v5.8.0.2] - 2019-06-20

### Added 

- Added resources for deployment of kubernetes manifests and helm charts on AKS using Azurefiles as persistent storage instead of NFS.

## [v5.8.0.1] - 2019-05-27

### Added
- Kubernetes resources for a simplified, WSO2 Identity Server deployment
- Kubernetes resources for WSO2 Identity and Access Management (IAM) [deployment patterns](https://docs.wso2.com/display/IS580/Deployment+Patterns)
- Helm resources for WSO2 Identity and Access Management (IAM) [deployment patterns](https://docs.wso2.com/display/IS580/Deployment+Patterns)
- Integrate support in Kubernetes resources for users with and without WSO2 subscriptions
- Integrate support in Helm resources for users with and without WSO2 subscriptions

[v5.8.0.2]: https://github.com/wso2/kubernetes-is/compare/v5.8.0.1...v5.8.0.2

## [V5.8.0.3] - Unreleased

### Added
- Added MySQL Helm chart as dependencies for deployment patterns
- Added InitContainer support in Helm resources
- Added security hardening
- Introduced Logstash for log aggregation and analysis

### Changed
- Promoted Helm resources as the single source of Kubernetes resource installation
- Parameterized datasource and clustering configurations
- Parameterized Kubernetes deployment definitions
- Set resource requests and limits for Kubernetes deployments

### Removed
- Removed sharing of persistent volumes in deployment patterns

[v5.8.0.3]: https://github.com/wso2/kubernetes-is/compare/v5.8.0.2...v5.8.0.3

For detailed information on the tasks carried out during this release, please see the GitHub milestone [5.8.0.3](https://github.com/wso2/kubernetes-is/milestone/3).
