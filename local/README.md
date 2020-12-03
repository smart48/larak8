# Local setup

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.

```
minikube start
```

## Local Namespace

To create a namespace based on file you can use this:

```
kubectl apply -f local/namespace.yml
```

Then this namespace can be used instead of default to launch your pods into.

## Local Ingress

Locally you can run an Ingress Nginx as well, but in a slightly different way

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

#### Enable Minikube Nginx Ingres 
To enable the NGINX Ingress controller, run the following command:

`minikube addons enable ingress`

Verify that the NGINX Ingress controller is running:

`kubectl get pods -n kube-system`

Deploy the Ingress controller using an example: `kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0`

## Local Persistent Volume

to use the storage for local testing apply the one in local directory 

```
kubectl apply -f local/storage/pv.yml
kubectl apply -f local/storage/pvc.yml
```

**NB** Not sure if we need the first one as well here.

and to check it has been created and is running we can use `kubectl get pv` and to delete all (dangerous) use `kubectl delete pvc --all`

*Notes on Persistent volume and testing still needed*

You also need to add persistent storage for the database containers so use

```
kubectl apply -f local/storage/mysql-pv-claim.yml
kubectl apply -f local/storage/redis-pv-claim.yml
```

## Local Deployments 

Local deployments are split in deployments for the app and other containers

To fire up the app with the Laravel and Nginx container run

```
kubectl apply -f local/deployments/app.yml
```

### Databases

To run the MySQL database and Redis containers run

```
kubectl apply -f local/deployments/mysql.yml
kubectl apply -f local/deployments/redis.yml
```
