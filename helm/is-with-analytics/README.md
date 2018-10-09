# Helm Chart for deployment of WSO2 Identity Server with WSO2 Identity Server Analytics

## Contents

* [Prerequisites](#prerequisites)
* [Quick Start Guide](#quick-start-guide)

## Prerequisites

* In order to use WSO2 Helm resources, you need an active WSO2 subscription. If you do not possess an active WSO2
  subscription already, you can sign up for a WSO2 Free Trial Subscription from [here](https://wso2.com/free-trial-subscription).<br><br>

* Install [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Helm](https://github.com/kubernetes/helm/blob/master/docs/install.md)
(and Tiller) and [Kubernetes client](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (compatible with v1.10) in order to run the 
steps provided in the following quick start guide.<br><br>

* An already setup [Kubernetes cluster](https://kubernetes.io/docs/setup/pick-right-solution/).<br><br>

* Install [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/deploy/). This can
 be easily done via 
  ```
  helm install stable/nginx-ingress --name nginx-wso2is-analytics --set rbac.create=true
  ```
  
## Quick Start Guide
>In the context of this document, <br>
>* `KUBERNETES_HOME` will refer to a local copy of the [`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/)
Git repository. <br>
>* `HELM_HOME` will refer to `<KUBERNETES_HOME>/helm/is-with-analytics`. <br>

##### 1. Clone the Kubernetes Resources for WSO2 Identity Server Git repository.

```
git clone https://github.com/wso2/kubernetes-is.git
```

##### 2. Setup a Network File System (NFS) to be used for persistent storage.

Create and export unique directories within the NFS server instance for each of the following Kubernetes Persistent Volume
resources defined in the `<HELM_HOME>/is-with-analytics/values.yaml` file:

* `sharedDeploymentLocationPath`
* `sharedTenantsLocationPath`

Grant ownership to `wso2carbon` user and `wso2` group, for each of the previously created directories.

  ```
  sudo chown -R wso2carbon:wso2 <directory_name>
  ```

Grant read-write-execute permissions to the `wso2carbon` user, for each of the previously created directories.

  ```
  chmod -R 700 <directory_name>
  ```

##### 3. Provide configurations.

a. The default product configurations are available at `<HELM_HOME>/is-with-analytics/confs` folder. Change the
configurations as necessary.

b. Open the `<HELM_HOME>/is-with-analytics/values.yaml` and provide the following values.

| Parameter                       | Description                                                                               |
|---------------------------------|-------------------------------------------------------------------------------------------|
| `username`                      | Your WSO2 username                                                                        |
| `password`                      | Your WSO2 password                                                                        |
| `email`                         | Docker email                                                                              |
| `namespace`                     | Kubernetes Namespace in which the resources are deployed                                  |
| `svcaccount`                    | Kubernetes Service Account in the `namespace` to which product instance pods are attached |
| `serverIp`                      | NFS Server IP                                                                             |
| `sharedDeploymentLocationPath`  | NFS shared deployment directory(`<IS_HOME>/repository/deployment`) location for IS       |
| `sharedTenantsLocationPath`     | NFS shared tenants directory(`<IS_HOME>/repository/tenants`) location for IS             |




##### 4. Deploy product database(s) using MySQL in Kubernetes.

```
helm install --name wso2is-with-analytics-rdbms-service -f <HELM_HOME>/mysql/values.yaml stable/mysql --namespace <NAMESPACE>
```

`NAMESPACE` should be same as in `step 3.b`.

For a serious deployment (e.g. production grade setup), it is recommended to connect product instances to a user owned and managed RDBMS instance.

##### 5. Deploy WSO2 Identity Server with WSO2 Identity Server Analytics.

```
helm install --name <RELEASE_NAME> <HELM_HOME>/is-with-analytics --namespace <NAMESPACE>
```

`NAMESPACE` should be same as in `step 3.b`.

##### 6. Access Management Console.

Default deployment will expose `wso2is` and `wso2is-analytics-dashboard` hosts (to expose Administrative services and Management Console).

To access the console in the environment,

a. Obtain the external IP (`EXTERNAL-IP`) of the Ingress resources by listing down the Kubernetes Ingresses.

```
kubectl get ing
```

```
NAME                                         HOSTS                         ADDRESS        PORTS     AGE
wso2is-with-analytics-is-dashboard-ingress   wso2is-analytics-dashboard   <EXTERNAL-IP>   80, 443   3m
wso2is-with-analytics-is-ingress             wso2is                       <EXTERNAL-IP>   80, 443   3m
``` 

b. Add the above host as an entry in /etc/hosts file as follows:

```
<EXTERNAL-IP>	wso2is-analytics-dashboard
<EXTERNAL-IP>	wso2is
```

c. Try navigating to `https://wso2is/carbon` and `https://wso2is-analytics-dashboard/portal` from your favorite browser.

