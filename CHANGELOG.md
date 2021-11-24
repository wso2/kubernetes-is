# Changelog

All notable changes to Kubernetes and Helm resources for WSO2 IAM version `5.11.x` in each resource release, will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## [v5.11.0.1] - 2021.11.24

### Added

- Integrate Kubernetes Startup Probe to Identity Server workload (refer [issue](https://github.com/wso2/kubernetes-is/issues/230))
- Use WSO2 Identity Server Health Check API for Kubernetes Readiness Probes (refer [issue](https://github.com/wso2/kubernetes-is/issues/252))

### Changed

- Upgrade the API version of Kubernetes Ingress resource (refer [issue](https://github.com/wso2/kubernetes-is/issues/312))
- Upgrade the API version of Kubernetes RoleBinding resource (refer [issue](https://github.com/wso2/kubernetes-is/issues/313))

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v5.11.0.5](https://github.com/wso2/kubernetes-is/milestone/13).

## [v5.11.0.4] - 2021.08.04

### Changed

- Optimise the IAM pod resources (refer [issue](https://github.com/wso2/kubernetes-is/issues/305)).

## [v5.11.0.3] - 2021.03.03

### Changed

- Fix is-pattern-1 template issue (refer [issue](https://github.com/wso2/kubernetes-is/issues/288)).

For detailed information on the tasks carried out during this release, please see the GitHub milestone
[v5.11.0.3](https://github.com/wso2/kubernetes-is/milestone/12).

## [v5.11.0.2] - 2020.12.17

### Changed

- Use update 2 images when subscription is enabled (refer [issue](https://github.com/wso2/kubernetes-is/issues/280) ).

## [v5.11.0.1] - 2020.12.03

### Added

- Introduce Kubernetes resources for simplified deployment of WSO2 Identity Server version `5.11.0`
- Introduce Helm chart for WSO2 IAM version `5.11.0` deployment pattern 1

[v5.11.0.1]: https://github.com/wso2/kubernetes-is/compare/v5.10.0.2...v5.11.0.1
[v5.11.0.2]: https://github.com/wso2/kubernetes-is/compare/v5.11.0.1...v5.11.0.2
[v5.11.0.3]: https://github.com/wso2/kubernetes-is/compare/v5.11.0.2...v5.11.0.3
