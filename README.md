# Smart48 Laravel Kubernetes

**This is still in alpha**

Kubernetes Deployment of Dockerized Laravel application at Digital Ocean. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- ingress nginx deployment
- app deployment including php fpm and nginx
- horizon deployment
- workspace deployment
- php worker

- code volume
- persistent volume container (pcv)

- autoscaler



## Digital Ocean Setup

This readme is on how to set all up on your Digital Ocean cluster. For local testing checking the local directory and readme there.
### Prerequisies

We assume you set up your cluster and recommend using our [Terraform setup](https://github.com/smart48/smt-provision) to set things up your way and with managed databases and DO Spaces for status. You can however use the DigitalOcean UI which is very nice too.

#### Authentication

https://www.digitalocean.com/docs/kubernetes/how-to/connect-to-cluster/

_To configure authentication from the command line, use the following command, substituting the name of your cluster._

`doctl kubernetes cluster kubeconfig save use_your_cluster_name`

This downloads the kubeconfig for the cluster, merges it with any existing configuration from `~/.kube/config`, and automatically handles the authentication token or certificate.

You can do this from the control panel as well. See documentation in link resource added here above.

#### Check Context


To check what your current context is and to make sure you are using DigitalOcean's configuration first do a 

```
kubectl config current-context
```

and to check all existing ones so you could see your minikube and the DigitalOcean context do a 

```
kubectl config get-contexts
```

To use a sepcific config to use DO K8 configuration use `kubectl config use-context do-sfo2-example-cluster-01` where you replace the _do-sfo2..._ part by your cluster name.



### DigitalOcean Namespace

To create a namespace based on file you can use this:

```
kubectl apply -f ./namespace.yml
```

Then this namespace can be used instead of default to launch your pods into.

### DigitalOcean Ingress

To install Ingress Nginx Kubernetes uses this official file for DigitalOcean setups:
`https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/scw/deploy.yaml`

using `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/scw/deploy.yaml`

We have added a copy of this to `deployments/ingress-nginx`

At https://marketplace.digitalocean.com/apps/nginx-ingress-controller they also mention the Nginx Ingress controller setup. This could be used after having set up the Ingress Nginx (Controller) using the above mentioned yaml file.

#### DO One Click  Ingress Nginx

There is however also an option to do a one click installation. See suggestion at https://github.com/jittagornp/kubernetes-demo and https://marketplace.digitalocean.com/apps/nginx-ingress-controller

_Note: The NGINX Ingress Controller 1-Click App also includes a $10/month DigitalOcean Load Balancer to ensure that ingress traffic is distributed across all of the nodes in your Kubernetes cluster._

_NB_ Load balancer as separate deployment made an example as it is included in one click installation and or Nginx installation via DO script.
#### DO Kubernetes Monitoring Stack

There is also a DigitalOcean one click install monitoring stack using Prometheus, Grafana, and metrics-server for deployment onto DigitalOcean Kubernetes clusters.

https://marketplace.digitalocean.com/apps/kubernetes-monitoring-stack


### DigitalOcean Storage

See https://www.digitalocean.com/community/tutorials/how-to-deploy-a-php-application-with-kubernetes-on-ubuntu-16-04#step-2-—-installing-the-digitalocean-storage-plug-in


See `storage/pvc.yml` in which we set up a Persistent Volume which can be accessed by a `PersistentVolumeClaim` or Persistent Volume Claim(PVC).

#### DO Storage Plugin Addition

To work with storage on Digital Ocean we first need to install a plugin. AS DO states at https://www.digitalocean.com/docs/kubernetes/ 

_We recommend against using HostPath volumes because nodes are frequently replaced and all data stored on the nodes will be lost._

For that we need to add a secret to be able to connect to DO and get this done. Add the access-token as stringData before you move on. We added the secret yaml file in the repository already. Just adjust it and add your key.

```
kubectl apply -f storage/secret.yaml
```

You can check the secret using `kubectl -n kube-system get secret digitalocean`. Once that is done you can download the plugin from the Digital Ocean repository:

```
kubectl apply -f https://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v0.3.0.yaml
```

### Persisent Storage Claim

One that is done we can create our Persistent Volume Claim with the following file application:

```
kubectl apply -f storage/pvc.yml
```

**NB** A separate Persistent Volume file is not needed here as we work with the DO plugin. For local Minikube setups we do.

#### Nginx configMap

A configMap for added Nginx configuration has been added to this repository and should be applied before the deployment is applied:

```
kubectl apply -f configs/nginx_configMap.yaml
```

**NB** Persistent Volume Claims do need to be up and running!

### DO App Deployments

We have multiple deployments to run all containers in one pod


- App including PHP FPM and Nginx
- Horizon
- PHP Worker
- Workspace


You can deploy these with:

 ```
 kubectl apply -f deployments/app.yml
 kubectl apply -f deployments/horizon.yml
 kubectl apply -f deployments/php-worker.yml
 kubectl apply -f deployments/workspace.yml
 ```


### DO Services

We are using Ingress Inginx as intial access point. We may however need to open up the app as well as workspace to allow access to these from outside the pod.

### DO Auto Scaler

https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/digitalocean

Autoscaler uses `HorizontalPodAutoscaler` as well which we may remove again as we do things during provisoning already.



## Resources

- [Lorenzo Aiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)
- [Coding Monk](https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478/)
- [Bill Willson](https://github.com/BillWilson/laravel-k8s-demo/)
- [Kubernetes Cheatsheets](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Digital Ocean how to deploy a PHP application](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-php-application-with-kubernetes-on-ubuntu-16-04)
- [Learning K8 Tutorial](https://learnk8s.io/blog/kubernetes-deploy-laravel-the-easy-way) - not on volumes