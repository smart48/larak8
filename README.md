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




## Test

Local testing of the deployment can be done with Minikube. Also see [notes](NOTES.md) on setup and possible issues.

```
minikube start
```

followed by 

```
kubectl apply -f web_deployment.yml
```


## Resources

- [Lorenzo Aiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)
- [Coding Monk](https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478/)
- [Bill Willson](https://github.com/BillWilson/laravel-k8s-demo/)