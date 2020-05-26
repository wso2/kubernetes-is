# Helm Chart for a Clustered Deployment of WSO2 Identity Server

## Contents

* [Prerequisites](#prerequisites)

* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* WSO2 product Docker images used for the Kubernetes deployment.
  
  WSO2 product Docker images available at [DockerHub](https://hub.docker.com/u/wso2/) package General Availability (GA)
  versions of WSO2 products with no [WSO2 Updates](https://wso2.com/updates).

  For a production grade deployment of the desired WSO2 product-version, it is highly recommended to use the relevant
  Docker image which packages WSO2 Updates, available at [WSO2 Private Docker Registry](https://docker.wso2.com/). In order
  to use these images, you need an active [WSO2 Subscription](https://wso2.com/subscription).
  <br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://helm.sh/docs/intro/install/)
  and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in order to run the steps provided in the
  following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup).<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/).<br><br>

* Add the WSO2 Helm chart repository.

    ```
     helm repo add wso2 https://helm.wso2.com && helm repo update
    ```
  
## Quick Start Guide

### Install Chart From [WSO2 Helm Chart Repository](https://hub.helm.sh/charts/wso2)

##### 1. Deploy Helm chart for a clustered deployment of WSO2 Identity Server.

[Option 1] Deploy using Docker images from DockerHub.

```
helm install --name <RELEASE_NAME> wso2/is-pattern-1 --version 5.10.0-1 --namespace <NAMESPACE> --set wso2.deployment.wso2is.host=<HOST>
```

[Option 2] Deploy WSO2 Identity Server using Docker images from WSO2 Private Docker Registry.

```
helm install --name <RELEASE_NAME> wso2/is-pattern-1 --version 5.10.0-1 --namespace <NAMESPACE> --set wso2.deployment.wso2is.host=<HOST> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```     
**Note:**

* `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed.
* `HOST` should be the host you'll use to access the deployment, the default is `localhost`.

##### 2. Access Management Console.
 
Navigate to `https://<HOST>/carbon` from your favorite browser.
 

### Install Chart From Source

>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced/`. <br>

##### 1. Clone the Kubernetes Resources for WSO2 Identity Server Git repository.

```
git clone https://github.com/wso2/kubernetes-is.git
```

##### 2. Deploy Helm chart for a clustered deployment of WSO2 Identity Server.

```
helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE> --set wso2.deployment.wso2is.host=<HOST>
```

* `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed
* `HOST` should be the host you'll use to access the deployment, the default is `localhost`.

[Option 1] Deploy using Docker images from DockerHub.

```
helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE> --set wso2.deployment.wso2is.host=<HOST>
```

[Option 2] Deploy WSO2 Identity Server using Docker images from WSO2 Private Docker Registry.

```
helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE> --set wso2.deployment.wso2is.host=<HOST> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

**Note:**

* `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed.
* `HOST` should be the host you'll use to access the deployment, the default is `localhost`.

##### 3. Access Management Console.

Navigate to `https://<HOST>/carbon` from your favorite browser.


## Configuration

The following tables lists the configurable parameters of the chart and their default values.

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | ""                          |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | ""                          |

###### Host

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2is.host`                                               | The host you'll use to access the deployment                                              | "localhost"                 |

###### Chart Dependencies

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.dependencies.mysql.enabled`                                | Enable MySQL chart as a dependency                                                        | true                        |
| `wso2.deployment.dependencies.nfsServerProvisioner.enabled`                 | Enable NFS Server Provisioner chart as a dependency                                       | true                        |

###### Persistent Runtime Artifact Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.persistentRuntimeArtifacts.nfsServerIP`                    | External NFS Server IP                                                                    | -                           |
| `wso2.deployment.persistentRuntimeArtifacts.sharedTenants`                  | Exported location on external NFS Server to be mounted at `<APIM_HOME>/repository/tenants` | -            |
| `wso2.deployment.persistentRuntimeArtifacts.sharedUserstores`               | Exported location on external NFS Server to be mounted at `<APIM_HOME>/repository/deployment/server/userstores` | -            |

**Note**: The above mentioned configurations are applicable only when, `wso2.deployment.dependencies.nfsProvisioner.enabled` is set to `false` and `wso2.persistentRuntimeArtifacts.cloudProvider` is set to `external-nfs`.

###### Identity Server Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2is.imageName`                                          | Image name for IS node                                                                    | wso2is                     |
| `wso2.deployment.wso2is.imageTag`                                           | Image tag for IS node                                                                     | 5.10.0                       |
| `wso2.deployment.wso2is.replicas`                                           | Number of replicas for IS node                                                            | 2                           |
| `wso2.deployment.wso2is.minReadySeconds`                                    | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#deploymentspec-v1-apps)| 30                        |
| `wso2.deployment.wso2is.strategy.rollingUpdate.maxSurge`                    | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#deploymentstrategy-v1-apps) | 1                           |
| `wso2.deployment.wso2is.strategy.rollingUpdate.maxUnavailable`              | Refer to [doc](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.12/#deploymentstrategy-v1-apps) | 0                           |
| `wso2.deployment.wso2is.livenessProbe.initialDelaySeconds`                  | Initial delay for the live-ness probe for IS node                                         | 120                           |
| `wso2.deployment.wso2is.livenessProbe.periodSeconds`                        | Period of the live-ness probe for IS node                                                 | 10                           |
| `wso2.deployment.wso2is.readinessProbe.initialDelaySeconds`                 | Initial delay for the readiness probe for IS node                                         | 120                           |
| `wso2.deployment.wso2is.readinessProbe.periodSeconds`                       | Period of the readiness probe for IS node                                                 | 10                           |
| `wso2.deployment.wso2is.imagePullPolicy`                                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | Always                       |
| `wso2.deployment.wso2is.resources.requests.memory`                          | The minimum amount of memory that should be allocated for a Pod                           | 2Gi                          |
| `wso2.deployment.wso2is.resources.requests.cpu`                             | The minimum amount of CPU that should be allocated for a Pod                              | 2000m                        |
| `wso2.deployment.wso2is.resources.limits.memory`                            | The maximum amount of memory that should be allocated for a Pod                           | 4Gi                          |
| `wso2.deployment.wso2is.resources.limits.cpu`                               | The maximum amount of CPU that should be allocated for a Pod                              | 4000m                        |

**Note**: The above mentioned default, minimum resource amounts for running WSO2 Identity Server profiles are based on its [official documentation](https://is.docs.wso2.com/en/5.10.0/setup/installation-prerequisites/).

###### Centralized Logging Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.centralizedLogging.enabled`                                           | Enable Centralized logging for WSO2 components                                            | false                        |                                                                                         |                             |    
| `wso2.centralizedLogging.logstash.imageTag`                                 | Logstash Sidecar container image tag                                                      | 7.2.0                       |  
| `wso2.centralizedLogging.logstash.elasticsearch.username`                   | Elasticsearch username                                                                    | elastic                     |  
| `wso2.centralizedLogging.logstash.elasticsearch.password`                   | Elasticsearch password                                                                    | changeme                    |  

###### Monitoring Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.monitoring.enabled`                                                   | Enable Prometheus monitoring                                                              | false                       |                                                                                         |                             |    
| `wso2.monitoring.prometheus.jmxJobName`                                     | Prometheus job name                                                                       | jmx                         |  
| `wso2.monitoring.prometheus.serviceMonitor.labels`                          | Prometheus labels for identifying Service Monitor                                         | "release: monitoring"       |  
| `wso2.monitoring.prometheus.serviceMonitor.blackBoxNamespace`               | Prometheus blackbox exporter namespace                                                    | <RELEASE_NAMESPACE>         |  

## Enabling Centralized Logging

Centralized logging with Logstash and Elasticsearch is disabled, by default. However, if it is required to be enabled, 
the following steps should be followed.

1. Set `wso2.centralizedLogging.enabled` to `true` in the [values.yaml](values.yaml) file.

2. Add elasticsearch Helm repository to download sub-charts required for centralized logging.

    ```
    helm repo add elasticsearch https://helm.elastic.co
    ```

3. Add the following dependencies in the [requirements.yaml](requirements.yaml) file.

    ```
    dependencies:
      - name: kibana
        version: "7.2.1-0"
        repository: "https://helm.elastic.co"
        condition: wso2.centralizedLogging.enabled
      - name: elasticsearch
        version: "7.2.1-0"
        repository: "https://helm.elastic.co"
        condition: wso2.centralizedLogging.enabled
    
    ```

4. Add override configurations for Elasticsearch in the [values.yaml](values.yaml) file.

    ```
    wso2:
      ( ... )
      
    elasticsearch:
      clusterName: wso2-elasticsearch
    ```
