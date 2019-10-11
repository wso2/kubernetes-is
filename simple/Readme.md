# Simplified setup for WSO2 kubernetes Identity Server

![WSO2 simplified Identity Server deployment](wso2is-simplified.png)

## Contents
* Prerequisites

* Quick Start Guide

## Prerequisites
* Install [Kubernetes  Client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the following quick start guide.
* An already setup Kubernetes cluster. If you are unfamiliar with this context, you can use [this guide](https://kubernetes.io/docs/setup/pick-right-solution/) to set up the cluster.

## Quick Start Guide
1. Download simplified kubernetes setup for WSO2 Identity Server (**deployment-scripts/wso2is-ga.sh**).
2. In the command line, move into the directory where you have downloaded the simplified kubernetes-is setup.
3. Provide permissions for the setup file to execute by running
```
chmod +x wso2is-ga.sh
```
4. Deploy WSO2 Identity Server in your cluster.

```
./wso2is-ga.sh --deploy
```

5. Try navigating to https://< NODE-IP >:30443/carbon/ your favourite browser using credentials admin/admin. Your < NODE-IP > will be provided at the end of the deployment.

6. Try out WSO2 Identity Server by following **[WSO2 Identity Server - Quick Start Guide](https://is.docs.wso2.com/en/5.9.0/)**.
