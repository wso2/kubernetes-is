# Kubernetes Resources for deployment of WSO2 Identity Server

Core Kubernetes resources for a [clustered deployment of WSO2 Identity Server](https://docs.wso2.com/display/IS580/Setting+Up+Deployment+Pattern+1).

![A clustered deployment WSO2 Identity Server](is.png)

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)


## Prerequisites

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with v1.10)
in order to run the steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* A pre-configured Network File System (NFS) to be used as the persistent volume for artifact sharing and persistence.
In the NFS server instance, create a Linux system user account named `wso2carbon` with user id `802` and a system group named `wso2` with group id `802`.
Add the `wso2carbon` user to the group `wso2`.

```
groupadd --system -g 802 wso2
useradd --system -g 802 -u 802 wso2carbon
```

## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/)
Git repository.<br>

##### 1. Clone the Kubernetes Resources for WSO2 Identity Server Git repository:

```
git clone https://github.com/wso2/kubernetes-is.git
```

##### 2. Create a namespace named `wso2` and a service account named `wso2svc-account`, within the namespace `wso2`.

```
kubectl create namespace wso2
kubectl create serviceaccount wso2svc-account -n wso2
```

Then, switch the context to new `wso2` namespace.

```
kubectl config set-context $(kubectl config current-context) --namespace=wso2
```

##### 3. Setup product database(s):

Setup the external product databases. Please refer to WSO2 Identity Server's [official documentation](https://docs.wso2.com/display/IS580/Setting+Up+Separate+Databases+for+Clustering)
on creating the required databases for the deployment.

Provide appropriate connection URLs, corresponding to the created external databases and the relevant driver class names for the data sources defined in
the following files:

* `<KUBERNETES_HOME>/is/confs/is/datasources/master-datasources.xml`
* `<KUBERNETES_HOME>/is/confs/is/datasources/bps-datasources.xml`

Please refer WSO2's [official documentation](https://docs.wso2.com/display/ADMIN44x/Configuring+master-datasources.xml) on configuring data sources.

**Note**:

* For **evaluation purposes**, you can use Kubernetes resources provided in the directory<br>
`<KUBERNETES_HOME>/is/extras/rdbms/mysql` for deploying the product databases, using MySQL in Kubernetes. However, this approach of product database deployment is
**not recommended** for a production setup.

* For using these Kubernetes resources,

    first create a Kubernetes ConfigMap for passing database script(s) to the deployment.
    
    ```
    kubectl create configmap mysql-dbscripts --from-file=<KUBERNETES_HOME>/is/extras/confs/mysql/dbscripts/
    ```
    
    Here, a Network File System (NFS) is needed to be used for persisting MySQL DB data.
    
    Create and export a directory within the NFS server instance.
    
    Provide read-write-execute permissions to other users for the created folder.
    
    Update the Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported,
    NFS server directory path (`NFS_LOCATION_PATH`) in `<KUBERNETES_HOME>/is/extras/rdbms/volumes/persistent-volumes.yaml`.
    
    Deploy the persistent volume resource and volume claim as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/is/extras/rdbms/mysql/mysql-persistent-volume-claim.yaml
    kubectl create -f <KUBERNETES_HOME>/is/extras/rdbms/volumes/persistent-volumes.yaml
    ```

    Then, create a Kubernetes service (accessible only within the Kubernetes cluster) and followed by the MySQL Kubernetes deployment, as follows:
    
    ```
    kubectl create -f <KUBERNETES_HOME>/is/extras/rdbms/mysql/mysql-service.yaml
    kubectl create -f <KUBERNETES_HOME>/is/extras/rdbms/mysql/mysql-deployment.yaml
    ```
    
##### 4. Create a Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

```
kubectl create -f <KUBERNETES_HOME>/rbac/rbac.yaml
```

##### 5. Setup a Network File System (NFS) to be used for persistent storage.

Create and export unique directories within the NFS server instance for each Kubernetes Persistent Volume resource defined in the
`<KUBERNETES_HOME>/is/volumes/persistent-volumes.yaml` file.

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

```
sudo chown -R wso2carbon:wso2 <directory_name>
```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

```
chmod -R 700 <directory_name>
```

Update each Kubernetes Persistent Volume resource with the corresponding NFS server IP (`NFS_SERVER_IP`) and exported, NFS server directory path (`NFS_LOCATION_PATH`).

Then, deploy the persistent volume resource and volume claim as follows:

```
kubectl create -f <KUBERNETES_HOME>/is/identity-server-volume-claims.yaml
kubectl create -f <KUBERNETES_HOME>/is/volumes/persistent-volumes.yaml
```

##### 6. Create Kubernetes ConfigMaps for passing WSO2 product configurations into the Kubernetes cluster:

```
kubectl create configmap identity-server-conf --from-file=<KUBERNETES_HOME>/is/confs/
kubectl create configmap identity-server-conf-axis2 --from-file=<KUBERNETES_HOME>/is/confs/axis2/
kubectl create configmap identity-server-conf-datasources --from-file=<KUBERNETES_HOME>/is/confs/datasources/
kubectl create configmap identity-server-conf-identity --from-file=<KUBERNETES_HOME>/is/confs/identity/
```

##### 7. Create Kubernetes Services and Deployments for WSO2 Identity Server:

```
kubectl create -f <KUBERNETES_HOME>/is/identity-server-service.yaml
kubectl create -f <KUBERNETES_HOME>/is/identity-server-deployment.yaml
```

##### 8. Deploy Kubernetes Ingress resource:

The WSO2 Identity Server Kubernetes Ingress resource uses the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

Finally, deploy the WSO2 Identity Server Kubernetes Ingress resources as follows:

```
kubectl create -f <KUBERNETES_HOME>/is/ingresses/identity-server-ingress.yaml
```

##### 9. Access Management Console:

Default deployment will expose `wso2is` host (to expose Administrative services and Management Console).

To access the console in the environment,

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

```
kubectl get ing
```

```
NAME                       HOSTS          ADDRESS        PORTS     AGE
wso2is-ingress             wso2is         <EXTERNAL-IP>  80, 443   3m
```

b. Add the above host as an entry in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2is
```

c. Try navigating to `https://wso2is/carbon` from your favorite browser.

##### 10. Scale up using `kubectl scale`:

Default deployment runs a single replica (or pod) of WSO2 Identity server. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/is/identity-server-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
