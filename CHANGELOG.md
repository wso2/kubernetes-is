# Changelog

All notable changes to Kubernetes and Helm resources for WSO2 IAM version 7.x will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [v7.1.0-1] - 2025-04-07

### Added

- Support for **WSO2 Identity Server 7.1.0** in Helm charts.
- `user_self_registration.callback_url` configuration in `deployment.toml` to enable self-registration use cases.
- Documentation improvements in the README for easier setup and deployment.

### Changed

- Updated keystore files to use `.p12` format for internal, primary, TLS, and truststore files.
- Made external keystore configuration **mandatory**, improving security and enabling B2B use cases.
- Updated Docker image tags and build version to align with WSO2 IS 7.1.0.
