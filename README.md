# Smart48 Laravel Deploy

Kubernetes Deployment of Dockerized Laravel application at Digital Ocean. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- php fpm deployment
- nginx deployment
- load balancer service
- cron job
- horizon deployment
- code volume

We still need to work on:

1. Workspace to take care of `php artisan` tasks,
2. PHP Worker for running supervisor and
3. rework the existing ones some more.


## Deployments

Option to run PHP FPM or Laravel App with Nginx and Load Balancer in one deployment. Nginx we use a standard base image and add configuration using the image. PHP FPM is a custom image wit all the needs of a Laravel application. The web deployment uses `HorizontalPodAutoscaler` as well which we may remove again as we do things during provisoning already.


### Local vs DO 

Local deployment uses a basic volume loading from the host whereas the DO deployment uses a persisent volume storage using the DO CSI plugin
### PHP Deployment

We are using a custom PHP FPM image. Laradock image still in this repository, but not in use.

### Nginx Deployment

For NGinx the same as for PHP FPM. We are using a custom image now. We may change this in the future.

### Cronjob

There is a [Kubernetes Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) we can use for Laravel schedules setup. Supervisor is still needed it seems though so we will keep the PHP Worker for now.

### Horizon

In progress based on code by [Lorenzo Asiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/) but adjusted to work with starter command properly.

## Kubernetes Deployment

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.

```
minikube start
```

followed by 

```
kubectl apply -f local_deployment.yml
```

### DO Deployment

To get the config
```
doctl kubernetes cluster kubeconfig save use_your_cluster_name
```
**NB** Perhaps you already did this and in that case just skip.


To use the Kube configuration:

```
kubectl --kubeconfig="use_your_kubeconfig.yaml"
```

For deploying to Digital Ocean we use 
```
kubectl apply -f do_deployment.yml
```

as well as the code_volume setup file.

To remove a deployment use `kubectl delete -n default deployment web`

## Services

Services - only load balancer or Nginx Ingress for now - will be found using:

```
kubectl get svc    
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP      10.96.0.1        <none>        443/TCP        5h10m
loadbalancer   LoadBalancer   10.105.166.110   <pending>     80:31931/TCP   5h8m
```

To use a load balancer and access it on Minikube use `minikube service loadbalancer` *after* you deployed the service. On Digital Ocean and other cloud providers you will get an external ip. In Minikube it stays pending. See [k8 resource](https://kubernetes.io/docs/tutorials/hello-minikube/#create-a-service).

We have load balancer as a separate `load_balancer.yml`. This so you can decide to use it or not. In our Terraform infra we have an Nginx Ingress as well and we may only use that and or make it optional in case one prefers a load balancer with Digital Ocean.


## Digital Ocean Storage

The [Digital Ocean storage plugin](https://github.com/digitalocean/csi-digitalocean) to work with block storage using the Container Storage Interface. 

_The CSI plugin allows you to use DigitalOcean Block Storage with your preferred Container Orchestrator._ [url](https://github.com/digitalocean/csi-digitalocean)

You can run the secret first getting access to DO:

```
kubectl apply -f secret.yaml
```

Make sure the secret has your access token added. Once secret has been applied you can run

```
kubectl apply -f https://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v1.0.0.yaml
```

to install the actual plugin.


### Persistent Volume

See `code_volume.yml` in which we set up a Persistent Volume which can be accessed by a `PersistentVolumeClaim` or Persistent Volume Claim(PVC).

```
kubectl apply -f code_volume.yaml
```

and to check it has been created and is running we can use `kubectl get pv`


### Digital Ocean Spaces

Spaces usage for storage [via the Spaces API should also be possible](https://www.digitalocean.com/docs/kubernetes/). It can be done with [Container Storage Interface (CSI) for S3](https://github.com/ctrox/csi-s3)

## Access Pod/Container

To list all pods in all namespaces use

```
kubectl get pods --all-namespaces 
```

and just the ones we launched with the deployment

```
kubectl get pods --namespace default
```

You can then access a pod by its name

```
kubectl exec -it web-84c8f5c8df-5bb7t -- /bin/bash
```

Use `kubectl describe pod/web-84c8f5c8df-5bb7t -n default` to see all of the containers in this pod. 

And use `kubectl exec -it web-84c8f5c8df-b9hhd -c nginx -- /bin/bash` to pick a specific container inside a pod.

## Resources

- [Lorenzo Aiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)
- [Coding Monk](https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478/)
- [Bill Willson](https://github.com/BillWilson/laravel-k8s-demo/)
- [Kubernetes Cheatsheets](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Digital Ocean how to deploy a PHP application](https://www.digitalocean.com/community/tutorials/how-to-deploy-a-php-application-with-kubernetes-on-ubuntu-16-04)