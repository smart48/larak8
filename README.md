# Smart48 Deployment

Package for Smart48 Deployment on Kubernetes. Package should be run after infrastructure has been set up.

Based on laravel-k8s-demo by Bill Willson https://github.com/BillWilson/laravel-k8s-demo 

`docker build . -f ./deploy/dockerfile -t laravel-on-k8s`

`docker tag laravel-on-k8s asia.gcr.io/[PROJECT_NAME]/laravel-k8s-demo`

```
kubectl apply -f deploy/app/secret.yml
kubectl apply -f deploy/app/deploy.yml
kubectl apply -f deploy/app/service.yml
```
