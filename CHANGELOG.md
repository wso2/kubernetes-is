# Changelog

All notable changes to Kubernetes and Helm resources for WSO2 IAM version 7.x will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---
## [v7.1.0-3] - 2025-05-20

### Changed

- Add OpenShift support for WSO2 Identity Server 7.1.0.
- Documentation improvements in the README for OpenShift deployment.

## [v7.1.0-2] - 2025-05-19

### Changed

- Made external keystore configuration false by default.
- Documentation improvements in the README for easier setup and deployment.

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