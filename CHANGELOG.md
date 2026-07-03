# Changelog

All notable changes to Kubernetes and Helm resources for WSO2 IAM version 7.x will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [v7.3.0-2] - 2026-07-03

### Changed

- Corrected the `imagePullSecrets` reference in `deployment.yaml` to use `.Values.deployment.image.imagePullSecret` instead of the non-existent
`.Values.wso2.deployment.image.imagePullSecret`, ensuring the configured image pull secret is applied correctly.

## [v7.3.0-1] - 2026-05-19

### Added

- Support for **WSO2 Identity Server 7.3.0** in Helm charts.
- Support for **Envoy Gateway** as an alternative ingress controller to Nginx.
- Added `GatewayClass`, `Gateway`, `HTTPRoute`, `EnvoyProxy`, and `BackendTLSPolicy` Kubernetes resource templates for Envoy Gateway integration.
- Added `deployment.gateway.enabled` flag in `values.yaml` to toggle between Nginx ingress and Envoy Gateway.
- Added `deployment.gateway.gatewayClassName`, `deployment.gateway.hostName`, and `deployment.gateway.tlsSecretsName` configuration options for Envoy Gateway.
- Added `deployment.gateway.backendCACertificate` configuration for Backend TLS between Envoy Gateway and WSO2 IS pods.
- Added `gatewayKindAPIVersions` section in `values.yaml` to configure Gateway API resource versions (`Gateway`, `GatewayClass`, `HTTPRoute`, `BackendTLSPolicy`, `EnvoyProxy`).

### Changed

- Updated Docker image tags and build version to align with WSO2 IS 7.3.0.
- Improved documentation in the README for Envoy Gateway integration and usage instructions.

## [v7.2.0-1] - 2025-11-12

### Added

- Support for **WSO2 Identity Server 7.2.0** in Helm charts.
- New `AgentIdentity` datasource configuration in `deployment.toml` for agent identity management.
- Enhanced secret store integration with support for agent identity database credentials.

### Changed

- Updated Docker image tags and build version to align with WSO2 IS 7.2.0.
- Enhanced database configuration with new agent identity database pool options.
- Improved documentation for agent identity management setup.

## [v7.1.0-1] - 2025-04-07

### Added

- Support for **WSO2 Identity Server 7.1.0** in Helm charts.
- `user_self_registration.callback_url` configuration in `deployment.toml` to enable self-registration use cases.
- Documentation improvements in the README for easier setup and deployment.

### Changed

- Updated keystore files to use `.p12` format for internal, primary, TLS, and truststore files.
- Made external keystore configuration **mandatory**, improving security and enabling B2B use cases.
- Updated Docker image tags and build version to align with WSO2 IS 7.1.0.

## [v7.0.0-2] - 2025-02-27

### Added

- Add IF Condition to disable AppArmor
- Add support for proxyPort configuration

## [v7.0.0-1] - 2024-03-12

### Added

- Introduce Helm resources for WSO2 Identity Server version `7.0.0`.
