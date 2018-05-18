# WSO2 Identity Server Kubernetes Resources 
*Kubernetes Resources for container-based deployments of WSO2 Identity Server (IS)*

kubernetes-is contains the deployment of a "scalable" unit of WSO2 IS server, 
running on <br> top of `Kubernetes` with `Docker` and `MySQL` support.

## Prerequisites

* Install [Docker](https://www.docker.com/get-docker)
* Setup a [Kubernetes Cluster](https://kubernetes.io/docs/setup/pick-right-solution/)
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
 
## Quick Start Guide

>In the context of this document, `KUBERNETES_HOME` will refer to a local copy of 
[`wso2/kubernetes-is`](https://github.com/wso2/kubernetes-is/) git repository

##### 1. Checkout WSO2 kubernetes-is repository using `git clone`:
```
git clone https://github.com/wso2/kubernetes-is.git
```

##### 2. Change directory to `KUBERNETES_HOME/dockerfiles` and build docker images following the guide in 
[`KUBERNETES_HOME/dockerfiles/README.md`](dockerfiles)

##### 3. Copy the Images in to Kubernetes Nodes or Registry:
Copy the required Docker images over to the Kubernetes Nodes (ex: use `docker save` to create a tarfile of the 
required image, `scp` the tarfile to each node, and use `docker load` to load the image from the copied tarfile 
on the nodes). Alternatively, if a private Docker registry is used, transfer the images there.

##### 4. Setup a Network File System (NFS) and update IS deployment YAML:
 
 * Network File System (NFS) is used as a shared persistent volume among Identity Server nodes. Therefore setting up NFS
  is required to deploy any pattern.
   Complete following.  
     1. Setup a NFS server.
     2. Update the NFS server IP in `KUBERNETES_HOME/pattern-X/is-nfs-persistent-volume.yaml'
     3. Create mount directory in NFS server for each pattern as mentioned in 
     `KUBERNETES_HOME/pattern-X/is-nfs-persistent-volume.yaml'
      eg: For pattern-1, create a directory as '/exports/'

##### 5. Deploy Kubernetes Resources:
Change directory to `KUBERNETES_HOME/pattern-X` and perform the deployment guide under each pattern.
eg: For pattern-1 change directory to `KUBERNETES_HOME/pattern-1` and perform the deployment as guided in
[`KUBERNETES_HOME/pattern-1/README.md`](pattern-1)

>To undeploy, follow the undeployment guide of the same.

##### 6. Access Management Console:
Each deployment will expose publicly accessible hosts based on the pattern.
To access the console in a test environment, add host entries in /etc/hosts file, pointing to respective Nginx 
Ingress cluster IP and access from your favorite browser.


