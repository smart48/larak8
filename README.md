# Smart48 Laravel Deploy

Kubernetes Deployment of Dockerized Laravel application. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- php fpm deployment and service
- nginx deployment and services

We still need to add 
1. Workspace,
2. PHP Worker

Both PHP deployment and Nginx deployment currently based on https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478


Nginx `Dockerfile` now also uses shell to copy over SSL certificates. We will not be using that as we will use Cert Manager instead. So that part commented out for now as well.

## Web Deployment

Option to run PHP FPM or Laravel App with Nginx in one deployment. Nginx we use a standard base image and add configuration using a configmap. Web deployment uses `HorizontalPodAutoscaler`

### PHP Deployment

Had copying over codebase command mentioned as used in Coding Monk's file. Now commented out as we will deploy using Circle Ci or PHP Deployer instead.

### Nginx Deployment

Laradock directory contains building blocks for Nginx image. It builds with copying over Nginx general configuration file, not the site files. There are site config examples however. The Nginx deployment file has an Nginx configuration map as well. This can be the main website `site.conf` file mentioned in the deployment. 

## Cronjob

There is a [Kubernetes Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) we can use for Laravel schedules setup. Supervisor is still needed it seems though so we will keep the PHP Worker for now.

## Horizon

In progress based on code by [Lorenzo Asiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/) but adjusted to work with starter command properly.

## Secrets

We cannot load secrets into configmaps so we need to use secrets where we do not want others to know the details about. Therefore the app config map may not be used.

We may use something like

```yml
ApiVersion: v1
kind: Pod
metadata: 
  labels: 
    context: docker-k8s-lab
    name: mysql-pod
  name: mysql-pod
spec: 
  containers:
  - image: "mysql:latest"
    name: mysql
    ports: 
    - containerPort: 3306
    envFrom:
      - secretRef:
         name: mysql-secret
```

with

```yml
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
type: Opaque
data:
  MYSQL_USER: bXlzcWwK
  MYSQL_PASSWORD: bXlzcWwK
  MYSQL_DATABASE: c2FtcGxlCg==
  MYSQL_ROOT_PASSWORD: c3VwZXJzZWNyZXQK
```

[Kubernetes Secrets SO thread](https://stackoverflow.com/questions/33478555/kubernetes-equivalent-of-env-file-in-docker?rq=1)

## Sources

[Lorenzo Aiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)
[Coding Monk](https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478/)
[Bill Willson](https://github.com/BillWilson/laravel-k8s-demo/)