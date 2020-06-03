# Smart48 Laravel Deploy

Kubernetes Deployment of Dockerized Laravel application. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- php fpm deployment and service
- nginx deployment and services

We still need to add 
1. Workspace,
2. PHP Worker


## Web Deployment

Option to run PHP FPM or Laravel App with Nginx in one deployment. Nginx we use a standard base image and add configuration using a configmap. Web deployment uses `HorizontalPodAutoscaler` which we may remove again as we do things during provisoning already.

### PHP Deployment

We are using a custom PHP FPM image. Laradock image still in this repository, but not in use.

### Nginx Deployment

For NGinx the same as for PHP FPM. We are using a custom image now. We may change this in the future.

## Cronjob

There is a [Kubernetes Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) we can use for Laravel schedules setup. Supervisor is still needed it seems though so we will keep the PHP Worker for now.

## Horizon

In progress based on code by [Lorenzo Asiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/) but adjusted to work with starter command properly.

## Kubernetes Deployment

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.

```
minikube start
```

followed by 

```
kubectl apply -f web_deployment.yml
```

## Services

Services will be found using

```
kubectl get svc    
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP      10.96.0.1        <none>        443/TCP        5h10m
loadbalancer   LoadBalancer   10.105.166.110   <pending>     80:31931/TCP   5h8m
```

To use a load balancer and access it on Minikube use `minikube service loadbalancer`. On Digital Ocean and other cloud providers you will get an external ip. In Minikube it stays pending. See [k8 resource](https://kubernetes.io/docs/tutorials/hello-minikube/#create-a-service)


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
-  [Kubernetes Cheatsheets](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)