# Local setup

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.


## Startup

To get Minikube running execute the following command:

```
minikube start
```

**NB** we mount our data volume right away so we can use it later on for our storage.

Then to check and make sure you have the proper context up and running do a

```
kubectl config current-context
```

It should show *minikube*

## Local Namespace

To create a namespace based on file you can use this:

```
kubectl apply -f local/namespace.yml
```

Then this namespace can be used instead of default to launch your pods into.

To check whethere the new namespace is there you can run

```
kubectl get namespaces
```
to make namespace default use 

```
kubectl config set-context --current --namespace=smt-local
```

## Local Ingress Controller

Locally you can run an Ingress Nginx as well, but in a slightly different way

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

#### Enable Minikube Nginx Ingres 
To enable the NGINX Ingress controller, run the following command:

```
minikube addons enable ingress
```

Verify that the NGINX Ingress controller is running:

```
kubectl get pods -n kube-system
```

## Ingress Resource 

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress-resource

To create a resource for your Ingress Nginx Controller to send traffic to your Service we need to set this up.

```
kubectl apply -f local/services/ingress.yml
```

Once this is up and running you can check for address and port with 

```
kubectl get ingress -n smt-local
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME               CLASS    HOSTS            ADDRESS        PORTS   AGE
ingress-resource   <none>   smart48k8.test   192.168.64.5   80      6m48s
```

**NBB** We added a host in this file called `smart48k8.local` and you do need to check `minikube ip` to attach this host to the ip in `/etc/host for it to load.

## Local Persistent Volume

resources:
- https://minikube.sigs.k8s.io/docs/handbook/persistent_volumes/
- https://stackoverflow.com/questions/45511339/kubernetes-minikube-with-local-persistent-storage

to use the storage for local testing apply the one in local directory 

_minikube supports PersistentVolumes of type hostPath out of the box. These PersistentVolumes are mapped to a directory inside the running minikube instance (usually a VM, unless you use --driver=none, --driver=docker, or --driver=podman). For more information on how this works, read the Dynamic Provisioning section below._

_In addition, minikube implements a very simple, canonical implementation of dynamic storage controller that runs alongside its deployment. This manages provisioning of hostPath volumes (rather then via the previous, in-tree hostPath provider)._
### Persisent volume claim


We will use the default dynamic storage class so no need to create volumes:

_...canonical implementation of dynamic storage controller that runs alongside its deployment._

https://platform9.com/blog/tutorial-dynamic-provisioning-of-persistent-storage-in-kubernetes-with-minikube/


```
kubectl apply -f local/storage/code-pv-claim.yml
kubectl apply -f local/storage/nginx-pv-claim.yml
kubectl apply -f local/storage/mysql-pv-claim.yml
kubectl apply -f local/storage/redis-pv-claim.yml
```

and to check it has been created and is running we can use `kubectl get pv` and to delete all (dangerous) use `kubectl delete pvc --all`

*Notes on Persistent volume and testing still needed*

To check where all is stored do a pcv check (tab in zsh allows choosing on of them):

```
kubectl describe pv pvc-.....
```

to see the Path. In the case of Redis with will be `/tmp/hostpath-provisioner/smt-local/redis-pv-claim` Then ssh into minikube using 

```
minkube ssh
```

and see:


```
cd /tmp/hostpath-provisioner/smt-local/              
$ ls -la
total 20
drwxr-xr-x 5 root root 4096 Dec  7 05:02 .
drwxr-xr-x 3 root root 4096 Dec  7 05:01 ..
drwxrwxrwx 2 root root 4096 Dec  7 06:57 code-pv-claim
drwxrwxrwx 7  999 root 4096 Dec  8 06:39 mysql-pv-claim
drwxrwxrwx 2 root root 4096 Dec  7 05:02 nginx-pv-claim
```

## Secrets

We do have a secret to store MySQL data

```
kubectl apply -f local/secret.yml
```


Example:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secrets
  namespace: smt-local
type: Opaque
data:
  # echo -n "root" | base64
  # mac echo -n 'root' | openssl base64
  ROOT_PASSWORD: cm9vdA==
  # password
  PASSWORD: cGFzc3dvcmQ=
```

**NB** We have not added a block for Redis yet
## Local Deployments 

Local deployments are split in deployments for the app and other containers

To fire up the app with the Laravel and Nginx container run

```
kubectl apply -f local/deployments/app.yml
```

then we have the other deployments excluding the databases:

```
kubectl apply -f local/deployments/php-worker.yml
kubectl apply -f local/deployments/workspace.yml
```
### Databases

To run the MySQL database and Redis containers run

```
kubectl apply -f local/deployments/mysql.yml
kubectl apply -f local/deployments/redis.yml
```


## Services 

```
kubectl apply -f local/services/app.yml
```