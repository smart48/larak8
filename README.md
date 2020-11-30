# Smart48 Laravel Kubernetes

Kubernetes Deployment of Dockerized Laravel application at Digital Ocean. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- ingress nginx deployment
- php fpm deployment
- nginx deployment
- horizon deployment
- workspace deployment

- code volume
- persistent volume container (pcv)

- autoscaler
- cron job with scheduler (multiple cronjobs)

We still need to work on:

1. Workspace to take care of `php artisan` tasks,
2. PHP Worker for running supervisor for queue and scheduler - may not be needed
3. rework the existing ones some more.


## Digital Ocean Setup
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

For that we need to add a secret to be able to connect to DO and get this done:

```
kubectl apply -f secret.yaml
```

You can check the secret using `kubectl -n kube-system get secret digitalocean`. Once that is done you can download the plugin from the Digital Ocean repository:

```
kubectl apply -f https://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v0.3.0.yaml
```

One that is done we can create our Persistent Volume Claim with the following file application:

```
kubectl apply -f storage/pvc.yml
```

**NB** A separate Persistent Volume file is not needed here as we work with the DO plugin. For local Minikube setups we do.

### DO App Deployments

Options to run these all in one pod and one web deployment:


- PHP FPM 
- Workspace
- Horizon
- Nginx Web Server

**NB** PHP Worker is still missing here.

with `kubectl apply -f deployments/web.yml`

#### Nginx configMap

A configMap for added Nginx configuration has been added to this repository and should be applied before the deployment is applied:

```
kubectl apply -f configs/nginx_configMap.yaml
```

**NB** Persistent Volume Claims do need to be up and running!


### DO Auto Scaler

https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler/cloudprovider/digitalocean

Autoscaler uses `HorizontalPodAutoscaler` as well which we may remove again as we do things during provisoning already.

### Cronjob

There is a [Kubernetes Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) we can use for Laravel schedules setup. Supervisor is still needed it seems though so we will keep the PHP Worker for now.


## Local setup

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.

```
minikube start
```

### Local Namespace

To create a namespace based on file you can use this:

```
kubectl apply -f ./namespace.yml
```

Then this namespace can be used instead of default to launch your pods into.

### Local Ingress

Locall you can run an Ingress Nginx as well, but in a slightly different way

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

`minikube start`

#### Enable Minikube Nginx Ingres 
To enable the NGINX Ingress controller, run the following command:

`minikube addons enable ingress`
Verify that the NGINX Ingress controller is running

`kubectl get pods -n kube-system`

Deploy the Ingress controller using an example: `kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0`

### Local Persistent Volume

to use the storage for local testing apply the one in local directory `kubectl apply -f local/pvc.yml`

and to check it has been created and is running we can use `kubectl get pv` and to delete all (dangerous) use `kubectl delete pvc --all`

*Notes on Persistent volume and testing still needed*
### Local Deployments 
```
kubectl apply -f local/deployment.yml
```

and to see the deployment up and running:

```
kubectl get deployments --all-namespaces
NAMESPACE              NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
kube-system            coredns                     2/2     2            2           176d
kubernetes-dashboard   dashboard-metrics-scraper   1/1     1            1           176d
kubernetes-dashboard   kubernetes-dashboard        1/1     1            1           176d
smt-prod               web                         0/2     2            0           35m
```

And you can use `kubectl get pods --all-namespaces` to check running pods



## Resources

- [Lorenzo Aiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)
- [Coding Monk](https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478/)
- [Bill Willson](https://github.com/BillWilson/laravel-k8s-demo/)
- [Kubernetes Cheatsheets](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Digital Ocean how to deploy a PHP application](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-php-application-with-kubernetes-on-ubuntu-16-04)
- [Learning K8 Tutorial](https://learnk8s.io/blog/kubernetes-deploy-laravel-the-easy-way)