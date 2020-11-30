# Smart48 Laravel Kubernetes

Kubernetes Deployment of Dockerized Laravel application at Digital Ocean. This deployment setup is still in alpha stage so cannot be used for production and even testing is limited. We currently have a basic

- php fpm deployment
- nginx deployment
- horizon deployment
- workspace deployment


- migrations (will probably be removed)

- code volume
- persistent volume container (pcv)

- autoscaler
- cron job with scheduler (multiple cronjobs)

We still need to work on:

1. Workspace to take care of `php artisan` tasks,
2. PHP Worker for running supervisor for queue and scheduler - may not be needed
3. rework the existing ones some more.


## Kubectl Checkup

```
kubectl version --client
Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.3", GitCommit:"2e7996e3e2712684bc73f0dec0200d64eec7fe40", GitTreeState:"clean", BuildDate:"2020-05-21T14:51:23Z", GoVersion:"go1.14.3", Compiler:"gc", Platform:"darwin/amd64"}
```

Start minikube for local work with `minikube start` . If you set up config:

```
cat ~/.kube/config 
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /Users/jasper/.minikube/ca.crt
    server: https://127.0.0.1:32768
  name: minikube
contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /Users/jasper/.minikube/profiles/minikube/client.crt
    client-key: /Users/jasper/.minikube/profiles/minikube/client.key
```
to work with your remotely set up Kubernetes cluster and you want to use that you do that. Example given here only shows local Kube setup. The `kubectl config view --minify` or `kubectl config current-context` shows current context. To show all use `kubectl config get-contexts` . 

Once Minikube is up you can do a quick check

```
kubectl cluster-info     
Kubernetes master is running at https://127.0.0.1:32768
KubeDNS is running at https://127.0.0.1:32768/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

You can also do `kubectl cluster-info dump` but that is a long story to go through and only needed occasionaly.


## Namespace

To create a namespace based on file you can use this:

```
kubectl apply -f ./namespace.yml
```

Then this namespace can be used instead of default to launch your pods into.

## Services

Data to be added on Nginx Ingress, part of provisioning. We did now however re-add the load balancer services so we can do a set up with Nginx Ingress as that may not be needed all the time or right away.

```
kubectl apply -f services/load-balancer.yml
```

## Digital Ocean Storage

The [Digital Ocean storage plugin](https://github.com/digitalocean/csi-digitalocean) to work with block storage using the Container Storage Interface. 

_The CSI plugin allows you to use DigitalOcean Block Storage with your preferred Container Orchestrator._ [url](https://github.com/digitalocean/csi-digitalocean)

You can run the secret first getting access to DO:

```
kubectl apply -f storage/secret.yaml
```

Make sure the secret has your access token added. Once secret has been applied you can run

```
kubectl apply -f https://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v1.0.0.yaml
```

to install the actual plugin.


### DigitalOcean Persistent Volume

See https://www.digitalocean.com/community/tutorials/how-to-deploy-a-php-application-with-kubernetes-on-ubuntu-16-04#step-2-—-installing-the-digitalocean-storage-plug-in


See `storage/pvc.yml` in which we set up a Persistent Volume which can be accessed by a `PersistentVolumeClaim` or Persistent Volume Claim(PVC).

#### DO Storage Plugin Addition

To work with storage on Digital Ocean we first need to install a plugin. For that we need to add a secret to be able to connect to DO and get this done:

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
### Local Persistent Volume

to use the storage for local testing apply the one in local directory `kubectl apply -f local/pvc.yml`

and to check it has been created and is running we can use `kubectl get pv` and to delete all (dangerous) use `kubectl delete pvc --all`

## Deployments

Options to run these all in one pod and one web deployment:

- Laravel Horizon 
- PHP FPM 
- Workspace
- Horizon

### configMap

A configMap for added Nginx configuration has been added to this repository and should be applied before the deployment is applied:

```
kubectl apply -f configs/nginx_configMap.yaml
```

### Web Deployment

Do run the web deployment do a 

```
kubectl apply -f deployments/web.yml
```

See more instructions further below on check as wel as the notes.

**NB** Persistent Volume Claims do need to be up and running!

#### Nginx and PHP FPM

Nginx we use a standard base image and add configuration using the image. PHP FPM is a custom image wit all the needs of a Laravel application. 

#### Workspace

Workspace to run PHP CLI commands including `php artisan` commands, but also `git`, `vim` and `nano`.


**NB** Local vs DO 

Local deployment uses a basic volume loading from the host whereas the DO deployment uses a persisent volume storage using the DO CSI plugin

#### Horizon

In progress based on code by [Lorenzo Asiello](https://lorenzo.aiello.family/running-laravel-on-kubernetes/) but adjusted to work with starter command properly.


## Auto Scaler

Autoscaler uses `HorizontalPodAutoscaler` as well which we may remove again as we do things during provisoning already.

## Cronjob

There is a [Kubernetes Cronjob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) we can use for Laravel schedules setup. Supervisor is still needed it seems though so we will keep the PHP Worker for now.


## Kubernetes Deployment

Local testing of the deployment can be done with Minikube. Also see [Notes](Notes.md) on setup and possible issues.

```
minikube start
```

followed by 

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
kubectl apply -f deployments/web.yml
```

as well as the code_volume setup file.

To remove a deployment use `kubectl delete -n default deployment web`


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
- [Learning K8 Tutorial](https://learnk8s.io/blog/kubernetes-deploy-laravel-the-easy-way)