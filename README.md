# Kubernetes and Helm Resources for WSO2 Identity And Access Management

*Kubernetes and Helm Resources for container-based deployments of WSO2 Identity Server deployment patterns.*

* A clustered deployment of WSO2 Identity Server

* A clustered deployment of WSO2 Identity Server with Analytics support

## Deploy Kubernetes resources

In order to deploy Kubernetes resources for each deployment pattern, follow the **Quick Start Guide** for each deployment pattern
given below:

### Simple

* [A Simplified Setup for  WSO2 Identity Server](simple/single-script/README.md)

### Advanced

**Note**: We consider Helm to be the primary source of installation of WSO2 product deployment patterns in Kubernetes environments. Hence, pure Kubernetes resources for product deployment patterns will be deprecated from 5.8.0.3 onwards. Please adjust your usage accordingly.

* [A clustered deployment of WSO2 Identity Server](advanced/is/README.md)

* [A clustered deployment of WSO2 Identity Server with Analytics support](advanced/is-with-analytics/README.md)

## Deploy Helm resources

In order to deploy Helm resources for each deployment pattern, follow the **Quick Start Guide** for each deployment pattern
given below:

* [A clustered deployment of WSO2 Identity Server](advanced/helm/is-pattern-1/README.md)

* [A clustered deployment of WSO2 Identity Server with Analytics support](advanced/helm/is-pattern-2/README.md)

## Advanced topics

* [Update product configurations](advanced/ManageConfigurations.md)
* [Introduce additional artifacts](advanced/ManageArtifacts.md)

## Changelog

**Change log** from previous v5.8.0.2 release: [View Here](CHANGELOG.md)

## Reporting issues

We encourage you to report any issues and documentation faults regarding Kubernetes and Helm resources
for WSO2 IAM. Please report your issues [here](https://github.com/wso2/kubernetes-is/issues).
