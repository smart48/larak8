# Smart48 Laravel Deploy

Kubernetes Deployment of Dockerized Laravel application. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- php fpm deployment and service
- nginx deployment and services

We still need to add 
1. Workspace,
2. PHP Worker

Both PHP deployment and Nginx deployment currently based on https://gist.github.com/CodingMonkTech/cafec3a17d2d29f595b01d5b394b0478

## PHP Deployment

Had copying over codebase command mentioned as used in Coding Monk's file. Now commented out as we will deploy using Circle Ci or PHP Deployer instead.

## Nginx Deployment

Laradock directory contains building blocks for Nginx image. It builds with copying over Nginx general configuration file, not the site files. There are site config examples however. The Nginx deployment file has an Nginx configuration map as well. This can be the main website `site.conf` file mentioned in the deployment. 

Nginx `Dockerfile` now also uses shell to copy over SSL certificates. We will not be using that as we will use Cert Manager instead. So that part commented out for now as well.


## Horizon

In progress based on code by [Lorenzo Asiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/)