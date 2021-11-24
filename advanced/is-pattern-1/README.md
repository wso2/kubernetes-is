# Helm Chart for a clustered deployment of WSO2 Identity Server

Resources for building a Helm chart for a clustered deployment of WSO2 Identity Server.

![A clustered deployment of WSO2 Identity Server](https://is.docs.wso2.com/en/latest/assets/img/setup/component-diagram.png)

For advanced details on the deployment pattern, please refer the official
[documentation](https://is.docs.wso2.com/en/latest/setup/deployment-guide/#deployment-patterns).

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)
* [Configuration](#configuration)
* [Runtime Artifact Persistence and Sharing](#runtime-artifact-persistence-and-sharing)
* [Managing Java Keystores and Truststores](#managing-java-keystores-and-truststores)
* [Centralized Logging](#centralized-logging)

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

* Ensure Kubernetes cluster has enough resources

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/).<br><br>

* Add the WSO2 Helm chart repository.

    ```
     helm repo add wso2 https://helm.wso2.com && helm repo update
    ```

## Quick Start Guide

### 1. Install the Helm Chart

You can install the relevant Helm chart either from [WSO2 Helm Chart Repository](https://artifacthub.io/packages/search?page=1&repo=wso2) or by source.

**Note:**

* `NAMESPACE` should be the Kubernetes Namespace in which the resources are deployed.

#### Install Chart From [WSO2 Helm Chart Repository](https://artifacthub.io/packages/search?page=1&repo=wso2)

 **Helm version 2**

 ```
 helm install --name <RELEASE_NAME> wso2/is-pattern-1 --version 5.11.0-5 --namespace <NAMESPACE>
 ```

 **Helm version 3**

 - Create the Kubernetes Namespace.
 
    ```
    kubectl create ns <NAMESPACE>
    ```

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> wso2/is-pattern-1 --version 5.11.0-5 --namespace <NAMESPACE>
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available at DockerHub.

If you are using WSO2 product Docker images available from WSO2 Private Docker Registry,
please provide your WSO2 Subscription Credentials via input values (using `--set` argument). 

Refer the following example.

 **Helm version 2**

```
 helm install --name <RELEASE_NAME> wso2/is-pattern-1 --version 5.11.0-5 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

 **Helm version 3**

```
 helm install <RELEASE_NAME> wso2/is-pattern-1 --version 5.11.0-5 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

#### Install Chart From Source

>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/advanced`. <br>

##### Clone the Helm Resources for WSO2 Identity Server Git repository.

```
git clone https://github.com/wso2/kubernetes-is.git
```

##### Deploy Helm chart for a clustered deployment of WSO2 Identity Server.

 **Helm version 2**

 ```
 helm install --dep-up --name <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE>
 ```

 **Helm version 3**

 - Create the Kubernetes Namespace to which you desire to deploy the Kubernetes resources.
 
    ```
    kubectl create ns <NAMESPACE>
    ```

 - Deploy the Kubernetes resources using the Helm Chart
 
    ```
    helm install <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE> --dependency-update
    ```

The above steps will deploy the deployment pattern using WSO2 product Docker images available at DockerHub.

If you are using WSO2 product Docker images available from WSO2 Private Docker Registry,
please provide your WSO2 Subscription Credentials via input values (using `--set` argument). 

Refer the following example.

```
 helm install --name <RELEASE_NAME> <HELM_HOME>/is-pattern-1 --namespace <NAMESPACE> --set wso2.subscription.username=<SUBSCRIPTION_USERNAME> --set wso2.subscription.password=<SUBSCRIPTION_PASSWORD>
```

### 2. Obtain the external IP

Obtain the external IP (`EXTERNAL-IP`) of the Identity Server Ingress resource, by listing down the Kubernetes Ingresses.

```  
kubectl get ing -n <NAMESPACE>
```

The output under the relevant column stands for the following.

- NAME: Metadata name of the Kubernetes Ingress resource (defaults to `wso2is-pattern-1-identity-server-ingress`)
- HOSTS: Hostname of the WSO2 Identity service (`<wso2.deployment.wso2is.ingress.identity.hostname>`)
- ADDRESS: External IP (`EXTERNAL-IP`) exposing the Identity service to outside of the Kubernetes environment
- PORTS: Externally exposed service ports of the Identity service

### 3. Add a DNS record mapping the hostname and the external IP

If the defined hostname (in the previous step) is backed by a DNS service, add a DNS record mapping the hostname and
the external IP (`EXTERNAL-IP`) in the relevant DNS service.

If the defined hostname is not backed by a DNS service, for the purpose of evaluation you may add an entry mapping the
hostname and the external IP in the `/etc/hosts` file at the client-side.

```
<EXTERNAL-IP> <wso2.deployment.wso2is.ingress.identity.hostname>
```

### 4. Access Management Console, Console and My Account

- Identity Server's Carbon Management Console: `https://<wso2.deployment.wso2is.ingress.identity.hostname>/carbon`
- Identity Server's Console: `https://<wso2.deployment.wso2is.ingress.identity.hostname>/console`
- Identity Server's My Account: `https://<wso2.deployment.wso2is.ingress.identity.hostname>/myaccount`

## Configuration

The following tables lists the configurable parameters of the chart and their default values.

###### WSO2 Subscription Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.subscription.username`                                                | Your WSO2 Subscription username                                                           | -                           |
| `wso2.subscription.password`                                                | Your WSO2 Subscription password                                                           | -                           |

> If you do not have an active WSO2 subscription, **do not change** the parameters `wso2.subscription.username` and `wso2.subscription.password`. 

###### Chart Dependencies

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.dependencies.mysql.enabled`                                | Enable the deployment and usage of WSO2 IAM MySQL based Helm Chart                        | true                        |

> We recommend you to persist the database data of the Kubernetes based MySQL deployment using an appropriate [Kubernetes StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/).
> You can achieve this by setting the property `mysql-is.mysql.persistence.storageClass` to the desired StorageClass.

> **Important:** In a production grade deployment, it is highly recommended to host the product databases in an external database server.

###### Persistent Runtime Artifact Configurations

| Parameter                                                                                   | Description                                                                               | Default Value               |
|---------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.persistentRuntimeArtifacts.storageClass`                                   | Appropriate Kubernetes Storage Class                                                      | -                           |
| `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.enabled`                        | Enable persistence/sharing of runtime artifacts between instances of the Identity Server profile        | false         |
| `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.capacity.tenants`               | Capacity for tenant data between Identity Server instances                                | 100M                        |
| `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.capacity.userstores`            | Capacity for secondary user stores between Identity Server instances                      | 50M                         |

> Please refer to the section [Runtime Artifact Persistence and Sharing](#runtime-artifact-persistence-and-sharing) for details.

###### Identity Server Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.deployment.wso2is.dockerRegistry`                                     | Registry location of the Docker image to be used to create Identity Server instances      | -                           |
| `wso2.deployment.wso2is.imageName`                                          | Name of the Docker image to be used to create Identity Server instances                   | `wso2is`                    |
| `wso2.deployment.wso2is.imageTag`                                           | Tag of the image used to create Identity Server instances                                 | `5.11.0`                    |
| `wso2.deployment.wso2is.imagePullPolicy`                                    | Refer to [doc](https://kubernetes.io/docs/concepts/containers/images#updating-images)     | `Always`                    |
| `wso2.deployment.wso2is.replicas`                                           | Number of replicas for IS node                                                            | 2                           |
| `wso2.deployment.wso2is.startupProbe.initialDelaySeconds`                   | Initial delay for the startup probe for IS node                                           | 60                          |
| `wso2.deployment.wso2is.startupProbe.periodSeconds`                         | Period of the startup probe for IS node                                                   | 5                           |
| `wso2.deployment.wso2is.startupProbe.failureThreshold`                      | Failed attempt count threshold of startup probe for IS node                               | 30                          |
| `wso2.deployment.wso2is.livenessProbe.periodSeconds`                        | Period of the live-ness probe for IS node                                                 | 10                          |
| `wso2.deployment.wso2is.readinessProbe.initialDelaySeconds`                 | Initial delay for the readiness probe for IS node                                         | 60                          |
| `wso2.deployment.wso2is.readinessProbe.periodSeconds`                       | Period of the readiness probe for IS node                                                 | 10                          |
| `wso2.deployment.wso2is.resources.requests.memory`                          | The minimum amount of memory that should be allocated for a Pod                           | 2Gi                         |
| `wso2.deployment.wso2is.resources.requests.cpu`                             | The minimum amount of CPU that should be allocated for a Pod                              | 1000m                       |
| `wso2.deployment.wso2is.resources.limits.memory`                            | The maximum amount of memory that should be allocated for a Pod                           | 4Gi                         |
| `wso2.deployment.wso2is.resources.limits.cpu`                               | The maximum amount of CPU that should be allocated for a Pod                              | 2000m                       |
| `wso2.deployment.wso2is.resources.jvm.heap.memory.xms`                      | The initial memory allocation for JVM Heap                                                | 1024m                       |
| `wso2.deployment.wso2is.resources.jvm.heap.memory.xmx`                      | The maximum memory allocation for JVM Heap                                                | 2048m                       |
| `wso2.deployment.wso2is.config`                                             | Custom deployment configuration file (`<WSO2IS>/repository/conf/deployment.toml`)         | -                           |
| `wso2.deployment.wso2is.ingress.className`                                  | Name of the Kubernetes IngressClass resource to use                                       | -                           |
| `wso2.deployment.wso2is.ingress.identity.hostname`                          | Hostname for for Identity service                                                         | `identity.wso2.com`         |
| `wso2.deployment.wso2is.ingress.identity.annotations`                       | Ingress resource annotations for Identity service                                         | Community NGINX Ingress controller annotations         |

> The above referenced default, minimum resource amounts for running WSO2 Identity Server profiles are based on its [official documentation](https://is.docs.wso2.com/en/latest/setup/installation-prerequisites/).

> The above referenced JVM settings are based on its [official documentation](https://is.docs.wso2.com/en/latest/setup/performance-tuning-recommendations/#jvm-settings).

###### Centralized Logging Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.centralizedLogging.enabled`                                           | Enable Centralized logging for WSO2 components                                            | false                       |  
| `wso2.centralizedLogging.logstash.imageTag`                                 | Logstash Sidecar container image tag                                                      | `7.8.1`                     |  
| `wso2.centralizedLogging.logstash.elasticsearch.username`                   | Elasticsearch username                                                                    | `elastic`                   |  
| `wso2.centralizedLogging.logstash.elasticsearch.password`                   | Elasticsearch password                                                                    | `changeme`                  |  

###### Monitoring Configurations

| Parameter                                                                   | Description                                                                               | Default Value               |
|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|-----------------------------|
| `wso2.monitoring.enabled`                                                   | Enable Prometheus monitoring                                                              | false                       |    
| `wso2.monitoring.prometheus.jmxJobName`                                     | Prometheus job name                                                                       | `jmx`                       |  
| `wso2.monitoring.prometheus.serviceMonitor.labels`                          | Prometheus labels for identifying Service Monitor                                         | `release: monitoring`       |  
| `wso2.monitoring.prometheus.serviceMonitor.blackBoxNamespace`               | Prometheus blackbox exporter namespace                                                    | <NAMESPACE>                 |  

## Runtime Artifact Persistence and Sharing

* In a production grade deployment, it is highly recommended to enable persistence and sharing of runtime artifacts such as, user stores and tenant data
  between instances of the Identity Server profile (i.e. set `wso2.deployment.persistentRuntimeArtifacts.sharedArtifacts.enabled` to true).

* It is **mandatory** to set an appropriate Kubernetes StorageClass when you enable this feature. Only persistent storage solutions supporting
  `ReadWriteMany` [access mode](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)
  are applicable for `wso2.deployment.persistentRuntimeArtifacts.storageClass`.
  
* Please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/store/Persisting_And_Sharing.md#recommended-storage-options-for-wso2-products)
  for advanced details with regard to WSO2 recommended, storage options.

## Managing Java Keystores and Truststores

For advanced details with regard to managing Java keystores and truststores in a container based WSO2 product deployment
please refer to the [official WSO2 container guide](https://github.com/wso2/container-guide/blob/master/deploy/Managing_Keystores_And_Truststores.md).

## Centralized Logging

* Centralized logging with Logstash and Elasticsearch is disabled, by default.

* However, if it is required to be enabled, the following steps should be adopted.

1. Set `wso2.centralizedLogging.enabled` to `true` in the [values.yaml](values.yaml) file.

2. Add Elasticsearch Helm repository to download sub-charts required for centralized logging.

    ```
    helm repo add elasticsearch https://helm.elastic.co
    ```

3. Add the following dependencies in the [requirements.yaml](requirements.yaml) file.

    ```
    dependencies:
      - name: kibana
        version: "7.8.1"
        repository: "https://helm.elastic.co"
        condition: wso2.centralizedLogging.enabled
      - name: elasticsearch
        version: "7.8.1"
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
