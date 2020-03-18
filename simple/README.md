# Kubernetes Resources for a Simplified WSO2 Identity Server Deployment

![Simplified WSO2 Identity Server Deployment](wso2is-simplified.png)

## Contents

* Prerequisites
* Quick Start Guide

## Prerequisites

* Install [Kubernetes  Client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps
provided in the following **Quick Start Guide**.

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup).

* In order to use Docker images with WSO2 Updates, you need an active [WSO2 Subscription](https://wso2.com/subscription).
Otherwise, you can proceed with Docker images available at [DockerHub](https://hub.docker.com/u/wso2/), which are created using GA releases.<br><br>

## Quick Start Guide

1. Download resources for deploying the simplified Kubernetes setup for WSO2 Identity Server ([`deployment-scripts`](deployment-scripts)).

2. Move into the directory, where you have downloaded the aforementioned resources in step 1.

3. Deploy WSO2 Identity Server in your Kubernetes cluster.

    * Deploy WSO2 Identity Server using Docker images from DockerHub.
    
        ```
        ./wso2is-ga.sh --deploy
        ```
    
    * Deploy WSO2 Identity Server using Docker images from [WSO2 Private Docker Registry](https://docker.wso2.com/).
    
        ```
        ./wso2is-latest.sh --deploy
        ```
      **Note**: When using images from WSO2 Private Docker Registry, you will be prompted for your WSO2 Subscription credentials.

4. Try navigating to `https://<NODE-IP>:30443/carbon/` your favourite browser using credentials `admin`/`admin`.
Your `<NODE-IP>` will be provided at the end of the deployment.

5. Try out WSO2 Identity Server by following **[WSO2 Identity Server - Quick Start Guide](https://is.docs.wso2.com/en/5.10.0/)**.
