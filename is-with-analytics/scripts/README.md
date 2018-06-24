# Kubernetes Test Resources for deployment of WSO2 Identity Server with WSO2 Identity Server Analytics

Kubernetes Test Resources for WSO2 Identity Server and Analytics contain artifacts, which can be used to test the core
Kubernetes resources provided for a clustered deployment of WSO2 Identity Server with WSO2 Identity Server Analytics.

## Prerequisites

* In order to use these Kubernetes resources, you will need an active [Free Trial Subscription](https://wso2.com/free-trial-subscription)
from WSO2 since the referring Docker images hosted at docker.wso2.com contains the latest updates and fixes for WSO2 Identity Server and
Identity Server Analytics. You can sign up for a Free Trial Subscription [here](https://wso2.com/free-trial-subscription).<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Docker](https://www.docker.com/get-docker)
(version 17.09.0 or above) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
in order to run the steps provided<br>in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/)<br><br>
 
## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/)
Git repository.<br>

##### 1. Checkout Kubernetes Resources for WSO2 Identity Server Git repository:

```
git clone https://github.com/wso2/kubernetes-is.git
```

##### 2. Deploy Kubernetes Ingress resource:

The WSO2 Identity Server Kubernetes Ingress resource uses the NGINX Ingress Controller.

In order to enable the NGINX Ingress controller in the desired cloud or on-premise environment,
please refer the official documentation, [NGINX Ingress Controller Installation Guide](https://kubernetes.github.io/ingress-nginx/deploy/).

##### 3. Setup a Network File System (NFS) to be used as the persistent volume for artifact sharing across Identity Server and Analytics instances.

Update the NFS server IP (`NFS_SERVER_IP`) and export path (`NFS_LOCATION_PATH`) of persistent volume resources,

* `wso2is-with-analytics-shared-deployment-pv`
* `wso2is-with-analytics-shared-tenants-pv`
* `wso2is-with-analytics-is-analytics-pv-1`
* `wso2is-with-analytics-is-analytics-pv-2`
* `wso2is-with-analytics-is-analytics-data-pv-1`
* `wso2is-with-analytics-is-analytics-data-pv-2`

in `<KUBERNETES_HOME>/is-with-analytics/volumes/persistent-volumes.yaml` file.

Create a user named `wso2carbon` with user id `802` and a group named `wso2` with group id `802` in the NFS node.
Add `wso2carbon` user to the group `wso2`.

Then, provide ownership of the exported folder `NFS_LOCATION_PATH` (used for artifact sharing) to `wso2carbon` user and `wso2` group.
And provide read-write-executable permissions to owning `wso2carbon` user, for the folder `NFS_LOCATION_PATH`.

Finally, setup a Network File System (NFS) to be used as the persistent volume for persisting MySQL DB data.
Provide read-write-executable permissions to `other` users, for the folder `NFS_LOCATION_PATH`.
Update the NFS server IP (`NFS_SERVER_IP`) and export path (`NFS_LOCATION_PATH`) of persistent volume resource
named `wso2is-with-analytics-mysql-pv` in the file `<KUBERNETES_HOME>/is-with-analytics/extras/rdbms/volumes/persistent-volumes.yaml`.

##### 4. Deploy Kubernetes resources:

Change directory to `KUBERNETES_HOME/is-with-analytics/scripts` and execute the `deploy.sh` shell script on the terminal, with the appropriate configurations as follows:

```
./deploy.sh --wso2-subscription-username=<WSO2_SUB_USERNAME> --wso2-subscription-password=<WSO2_SUB_PASSWORD> --cluster-admin-password=<K8S_CLUSTER_ADMIN_PASSWORD>
```

* A Kubernetes Secret named `wso2creds` in the cluster to authenticate with the [`WSO2 Docker Registry`](https://docker.wso2.com), to pull the required images.
The following details need to be replaced in the relevant command.

`WSO2_SUB_USERNAME`: Username of your WSO2 Subscription<br>
`WSO2_SUB_PASSWORD`: Password of your WSO2 Subscription

* A Kubernetes role and a role binding necessary for the Kubernetes API requests made from Kubernetes membership scheme.

`K8S_CLUSTER_ADMIN_PASSWORD`: Kubernetes cluster admin password

>To un-deploy, be on the same directory and execute the `undeploy.sh` shell script on the terminal.

##### 5. Access Management Consoles:

Default deployment will expose `wso2is` and `wso2is-analytics` hosts (to expose Administrative services and Management Console).

To access the console in the environment,

1. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses (using `kubectl get ing`).

e.g.

```
NAME                                         HOSTS              ADDRESS        PORTS     AGE
wso2is-with-analytics-is-analytics-ingress   wso2is-analytics   <EXTERNAL-IP>   80, 443   3m
wso2is-with-analytics-is-ingress             wso2is             <EXTERNAL-IP>   80, 443   3m
```

2. Add the above host as an entry in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2is-analytics
<EXTERNAL-IP>	wso2is
```

3. Try navigating to `https://wso2is/carbon` and `https://wso2is-analytics/carbon` from your favorite browser.

##### 6. Scale up using `kubectl scale`:

Default deployment runs two replicas (or pods) of WSO2 Identity server. To scale this deployment into any `<n>` number of
container replicas, upon your requirement, simply run following Kubernetes client command on the terminal.

```
kubectl scale --replicas=<n> -f <KUBERNETES_HOME>/is/identity-server-deployment.yaml
```

For example, If `<n>` is 2, you are here scaling up this deployment from 1 to 2 container replicas.
