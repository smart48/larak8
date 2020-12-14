# Notes


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


Notes on issues encountered setting up this deployment. Also notes with background stories on usage of load balancers and Nginx ingresses, volumes and such.

## Local Docker on OSX

Docker needs to be running so make sure you installed Docker for MacOS. 

## Minikube

Also you should have Minikube installed. With MacOS that is with `brew install minikube` . To upgrade use `brew upgrade minikube` and perhaps `brew link minikube`.

```
brew link minikube
Linking /usr/local/Cellar/minikube/1.11.0... 3 symlinks created
```

Then start Minikube which may download a new Kubernetes version and driver:

```
minikube start    
😄  minikube v1.11.0 on Darwin 10.15.5
✨  Using the hyperkit driver based on existing profile
💾  Downloading driver docker-machine-driver-hyperkit:
    > docker-machine-driver-hyperkit.sha256: 65 B / 65 B [---] 100.00% ? p/s 0s
    > docker-machine-driver-hyperkit: 10.90 MiB / 10.90 MiB  100.00% 2.41 MiB p
🔑  The 'hyperkit' driver requires elevated permissions. The following commands will be executed:

    $ sudo chown root:wheel /Users/jasper/.minikube/bin/docker-machine-driver-hyperkit 
    $ sudo chmod u+s /Users/jasper/.minikube/bin/docker-machine-driver-hyperkit 


Password:
🆕  Kubernetes 1.18.3 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.18.3
🆕  Kubernetes 1.18.3 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.18.3
🆕  Kubernetes 1.18.3 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.18.3
💿  Downloading VM boot image ...
    > minikube-v1.11.0.iso.sha256: 65 B / 65 B [-------------] 100.00% ? p/s 0s
    > minikube-v1.11.0.iso: 174.99 MiB / 174.99 MiB [] 100.00% 4.43 MiB p/s 39s
👍  Starting control plane node minikube in cluster minikube
💾  Downloading Kubernetes v1.17.0 preload ...
    > preloaded-images-k8s-v3-v1.17.0-docker-overlay2-amd64.tar.lz4: 522.40 MiB
🔄  Restarting existing  VM for "minikube" ...
❗  This VM is having trouble accessing https://k8s.gcr.io
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
💡  Existing disk is missing new features (lz4). To upgrade, run 'minikube delete'
🐳  Preparing Kubernetes v1.17.0 on Docker 19.03.5 ...
    > kubectl.sha256: 65 B / 65 B [--------------------------] 100.00% ? p/s 0s
    > kubelet.sha256: 65 B / 65 B [--------------------------] 100.00% ? p/s 0s
    > kubeadm.sha256: 65 B / 65 B [--------------------------] 100.00% ? p/s 0s
    > kubelet: 106.39 MiB / 106.39 MiB [-------------] 100.00% 4.93 MiB p/s 22s
    > kubectl: 41.48 MiB / 41.48 MiB [---------------] 100.00% 1.39 MiB p/s 30s
    > kubeadm: 37.52 MiB / 37.52 MiB [-------------] 100.00% 977.04 KiB p/s 40s
🔎  Verifying Kubernetes components...
❗  Enabling 'default-storageclass' returned an error: running callbacks: [Error getting storagev1 interface client config: invalid configuration: [unable to read client-cert /Users/jasper/.minikube/profiles/minikube/client.crt for minikube due to open /Users/jasper/.minikube/profiles/minikube/client.crt: no such file or directory, unable to read client-key /Users/jasper/.minikube/profiles/minikube/client.key for minikube due to open /Users/jasper/.minikube/profiles/minikube/client.key: no such file or directory] : client config: invalid configuration: [unable to read client-cert /Users/jasper/.minikube/profiles/minikube/client.crt for minikube due to open /Users/jasper/.minikube/profiles/minikube/client.crt: no such file or directory, unable to read client-key /Users/jasper/.minikube/profiles/minikube/client.key for minikube due to open /Users/jasper/.minikube/profiles/minikube/client.key: no such file or directory]]
🌟  Enabled addons: default-storageclass, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube"
```

**NB** To deal with the client certificates not loading see [minikube issue](https://github.com/kubernetes/minikube/issues/8363). Basically path to them was off at `~/.kube/config` in our case.

## Kubctl Issues

We had several issues making deployments work:

- apiVersion issue
- selector field missing issue

```
kubectl apply -f web_deployment.yml 
horizontalpodautoscaler.autoscaling/web created
service/loadbalancer created
error: unable to recognize "web_deployment.yml": no matches for kind "Deployment" in version "apps/v1beta1"
```

```
kubectl api-resources | grep deployment
deployments                       deploy       apps                           true         Deployment
```
_This means that only apiVersion with apps is correct for Deployments (extensions is not supporting Deployment). The same situation with StatefulSet._

So `apps/v1` needed instead of `apps/v1beta` for `web_deployment.yml`

[so thread](https://stackoverflow.com/a/58482194/460885)

```
kubectl apply -f web_deployment.yml
error: error validating "web_deployment.yml": error validating data: ValidationError(Deployment.spec): missing required field "selector" in io.k8s.api.apps.v1.DeploymentSpec; if you choose to ignore these errors, turn validation off with --validate=false
```

Do a `kubectl delete deployment web` before deploying with selector again. Once done all will be fine

```
kubectl apply -f web_deployment.yml
deployment.apps/web created
horizontalpodautoscaler.autoscaling/web unchanged
service/loadbalancer unchanged
```

## Minikube Central

```
kubectl cluster-info                   
Kubernetes master is running at https://192.168.64.3:8443
KubeDNS is running at https://192.168.64.3:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

[Kubernetes Master](https://192.168.64.3:8443/) has a 403

## Network Issues OSX

Pods issues with `ImagePullBackoff`:

```
kubectl get po --namespace default 
NAME                   READY   STATUS             RESTARTS   AGE
web-64c5bc5fdf-4kp58   0/2     ImagePullBackOff   0          3m33s
web-64c5bc5fdf-fl8jb   0/2     ImagePullBackOff   0          3m33s
web-64c5bc5fdf-mdlw6   0/2     ImagePullBackOff   0          3m33s
```

And checking one of the pods I saw

```
kubectl describe pod web-64c5bc5fdf-4kp58
Name:         web-64c5bc5fdf-4kp58
Namespace:    default
Priority:     0
Node:         minikube/192.168.64.3
  ...
  Type     Reason     Age                   From               Message
  ----     ------     ----                  ----               -------
  Normal   Scheduled  7m5s                  default-scheduler  Successfully assigned default/web-64c5bc5fdf-4kp58 to minikube
  Warning  Failed     7m4s                  kubelet, minikube  Failed to pull image "smart48/smt-laravel:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.64.1:53: read udp 192.168.64.3:53726->192.168.64.1:53: read: connection refused
  Warning  Failed     7m3s                  kubelet, minikube  Failed to pull image "smart48/smt-nginx:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.64.1:53: read udp 192.168.64.3:33268->192.168.64.1:53: read: connection refused
  Warning  Failed     6m51s                 kubelet, minikube  Failed to pull image "smart48/smt-nginx:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.64.1:53: read udp 192.168.64.3:43430->192.168.64.1:53: read: connection refused
  Warning  Failed     6m51s                 kubelet, minikube  Failed to pull image "smart48/smt-laravel:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.64.1:53: read udp 192.168.64.3:43183->192.168.64.1:53: read: connection refused
  Warning  Failed     6m37s (x2 over 7m2s)  kubelet, minikube  Error: ImagePullBackOff
  Normal   BackOff    6m37s (x2 over 7m2s)  kubelet, minikube  Back-off pulling image "smart48/smt-nginx:latest"
  Normal   BackOff    6m37s (x2 over 7m3s)  kubelet, minikube  Back-off pulling image "smart48/smt-laravel:latest"
  Warning  Failed     6m26s (x3 over 7m3s)  kubelet, minikube  Error: ErrImagePull
  Normal   Pulling    6m26s (x3 over 7m4s)  kubelet, minikube  Pulling image "smart48/smt-nginx:latest"
  Warning  Failed     6m26s (x3 over 7m4s)  kubelet, minikube  Error: ErrImagePull
  Normal   Pulling    6m26s (x3 over 7m4s)  kubelet, minikube  Pulling image "smart48/smt-laravel:latest"
  Warning  Failed     6m26s                 kubelet, minikube  Failed to pull image "smart48/smt-laravel:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry-1.docker.io/v2/: dial tcp: lookup registry-1.docker.io on 192.168.64.1:53: read udp 192.168.64.3:51968->192.168.64.1:53: read: connection refused
  Warning  Failed     117s (x21 over 7m3s)  kubelet, minikube  Error: ImagePullBackOff
  ```

Seemed again to be a network / Dnsmasq / Virtual network setup issues.

_open `/usr/local/etc/dnsmasq.conf` and edit to taste. (uncomment listen-address and set it to the gateway)_ is an option. [url](https://github.com/kubernetes/minikube/issues/3104)

cascading configurations:

```
➜  smt-deploy git:(master) ✗ nano /usr/local/etc/dnsmasq.conf
➜  smt-deploy git:(master) ✗ nano /usr/local/etc/dnsmasq.d/dnsmasq-valet.conf
➜  smt-deploy git:(master) ✗ nano /Users/jasper/.config/valet/dnsmasq.d/tld-test.conf 
```

So we did a `minikube delete` and then `minikube start --driver=docker` [tip](https://github.com/kubernetes/minikube/issues/6296)


**NB** See later in notes how we did get hypervisor up and running with dnsmasq config changes which also allowed us to run ingress nginx locally on Minikube.

```
minikube start --driver=docker
😄  minikube v1.11.0 on Darwin 10.15.5
✨  Using the docker driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.18.3 preload ...
    > preloaded-images-k8s-v3-v1.18.3-docker-overlay2-amd64.tar.lz4: 526.01 MiB
🔥  Creating docker container (CPUs=2, Memory=2948MB) ...
🐳  Preparing Kubernetes v1.18.3 on Docker 19.03.2 ...
    ▪ kubeadm.pod-network-cidr=10.244.0.0/16
...
```    
instead of default `minikube start --driver=hyperkit` run when we run `minikube start` on OSX. Then we had to see if dnsmasq was still interfering or not. And yes, it seemed to work just fine

```
➜  smt-deploy git:(master) ✗ kubectl apply -f web_deployment.yml
deployment.apps/web created
horizontalpodautoscaler.autoscaling/web created
service/loadbalancer created
➜  smt-deploy git:(master) ✗ kubectl get po --namespace default 
NAME                   READY   STATUS              RESTARTS   AGE
web-848fb4c7dc-5m2fp   0/2     ContainerCreating   0          6s
web-848fb4c7dc-ffv7n   0/2     ContainerCreating   0          6s
web-848fb4c7dc-mg65j   0/2     ContainerCreating   0          6s
```


## Container Issues


But we hit errors again:

```
➜  smt-deploy git:(master) ✗ kubectl get po --namespace default 
NAME                   READY   STATUS             RESTARTS   AGE
web-848fb4c7dc-5m2fp   1/2     CrashLoopBackOff   2          109s
web-848fb4c7dc-ffv7n   1/2     Error              2          109s
web-848fb4c7dc-mg65j   1/2     CrashLoopBackOff   2          109s
```

So we checked the pod again

```
kubectl describe pod web-848fb4c7dc-ffv7n
Name:         web-848fb4c7dc-ffv7n
Namespace:    default
Priority:     0
Node:         minikube/172.17.0.3
Start Time:   Wed, 03 Jun 2020 08:55:37 +0700
Labels:       app=web
              pod-template-hash=848fb4c7dc
Annotations:  <none>
Status:       Running
IP:           172.18.0.5
IPs:
  IP:           172.18.0.5
Controlled By:  ReplicaSet/web-848fb4c7dc
Containers:
  laravel:
    Container ID:   docker://364a1f88d050c11553eaf4c92594ab1964add3ca2cfacb0c667a918e828810a5
    Image:          smart48/smt-laravel:latest
    Image ID:       docker-pullable://smart48/smt-laravel@sha256:b30ab56ed57b636bed8821e956645f00e26b6b9aabd2d7dc1362b531db70ceae
    Port:           9000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 03 Jun 2020 08:56:25 +0700
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:  500m
    Requests:
      cpu:        250m
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7lxgn (ro)
  nginx:
    Container ID:   docker://943d7433890b49e1f1e78656f85c79c10c3c9fa4c8a530283b21ceded748eca1
    Image:          smart48/smt-nginx:latest
    Image ID:       docker-pullable://smart48/smt-nginx@sha256:c01334c0609872414a297295b11622a3886c102d229dae6fd4b5af87eb2d2e82
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Wed, 03 Jun 2020 08:57:51 +0700
      Finished:     Wed, 03 Jun 2020 08:57:51 +0700
    Ready:          False
    Restart Count:  3
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7lxgn (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-7lxgn:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-7lxgn
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  2m30s               default-scheduler  Successfully assigned default/web-848fb4c7dc-ffv7n to minikube
  Normal   Pulling    2m29s               kubelet, minikube  Pulling image "smart48/smt-laravel:latest"
  Normal   Pulled     102s                kubelet, minikube  Successfully pulled image "smart48/smt-laravel:latest"
  Normal   Created    102s                kubelet, minikube  Created container laravel
  Normal   Started    102s                kubelet, minikube  Started container laravel
  Normal   Pulling    23s (x4 over 102s)  kubelet, minikube  Pulling image "smart48/smt-nginx:latest"
  Normal   Pulled     16s (x4 over 81s)   kubelet, minikube  Successfully pulled image "smart48/smt-nginx:latest"
  Normal   Created    16s (x4 over 81s)   kubelet, minikube  Created container nginx
  Normal   Started    16s (x4 over 81s)   kubelet, minikube  Started container nginx
  Warning  BackOff    16s (x5 over 69s)   kubelet, minikube  Back-off restarting failed container
```

Writing about it in [K8 Community thread](https://discuss.kubernetes.io/t/laravel-app-nginx-crashloopbackoff/11233) I realized we had a container issue. So might have to switch to our own hand rolled images instead of PHP FPM / Nginx by Laradock which demand each other's presence.

So we rebuild the images using different specs and now we did

```
kubectl rollout restart deployments
deployment.apps/web restarted
kubectl get po --namespace default 
NAME                  READY   STATUS    RESTARTS   AGE
web-fbd58c4c7-4rdxw   2/2     Running   0          38s
web-fbd58c4c7-rmmm2   2/2     Running   0          38s
web-fbd58c4c7-snzdx   2/2     Running   0          21s
```
## Pods + Containers


_In other words, if you need to run a single container in Kubernetes, then you need to create a Pod for that container. At the same time, a Pod can contain more than one container, usually because these containers are relatively tightly coupled. How tightly coupled?  Well, think of it this way: the containers in a pod represent processes that would have run on the same server in a pre-container world._

[Mirantis](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/)


### Meta Data

_Every object kind MUST have the following metadata in a nested object field called "metadata":namespace: a namespace is a DNS compatible label that objects are subdivided into. The default namespace is 'default'. See the namespace docs for more._

[meta data docs](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata)


### Pod related commands

Describe is used to get basic information about your pod:

```
kubectl describe pod/web-84c8f5c8df-5bb7t -n default
Name:         web-84c8f5c8df-5bb7t
Namespace:    default
Priority:     0
Node:         minikube/172.17.0.2
Start Time:   Wed, 03 Jun 2020 15:33:36 +0700
Labels:       app=web
              pod-template-hash=84c8f5c8df
Annotations:  <none>
Status:       Running
IP:           172.18.0.3
IPs:
  IP:           172.18.0.3
Controlled By:  ReplicaSet/web-84c8f5c8df
Containers:
  laravel:
    Container ID:   docker://f440b3b4fe8b3f1721a83b547e09d577d39e51d32aee2d73389723c867dc3bd2
    Image:          smart48/smt-laravel:latest
    Image ID:       docker-pullable://smart48/smt-laravel@sha256:35202976150b7d80dc84124bdc6753e2c88b954ce6d0ae4e1eb47145f822bb03
    Port:           9000/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 03 Jun 2020 15:33:41 +0700
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:  500m
    Requests:
      cpu:        250m
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7lxgn (ro)
  nginx:
    Container ID:   docker://b4377cfff6113051a134ce1832b337680bc067bb06e920a29ebd37288e6a923a
    Image:          smart48/smt-nginx:latest
    Image ID:       docker-pullable://smart48/smt-nginx@sha256:68d5e204bb05a91f8e1dadbd2f995ee0ea92516d89d59e23931869a2aa59bc89
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 03 Jun 2020 15:33:51 +0700
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-7lxgn (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  dir:
    Type:          HostPath (bare host directory volume)
    Path:          /var/www
    HostPathType:
  default-token-7lxgn:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-7lxgn
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age        From               Message
  ----    ------     ----       ----               -------
  Normal  Scheduled  <unknown>  default-scheduler  Successfully assigned default/web-84c8f5c8df-5bb7t to minikube
  Normal  Pulling    9m26s      kubelet, minikube  Pulling image "smart48/smt-laravel:latest"
  Normal  Pulled     9m23s      kubelet, minikube  Successfully pulled image "smart48/smt-laravel:latest"
  Normal  Created    9m22s      kubelet, minikube  Created container laravel
  Normal  Started    9m22s      kubelet, minikube  Started container laravel
  Normal  Pulling    9m22s      kubelet, minikube  Pulling image "smart48/smt-nginx:latest"
  Normal  Pulled     9m12s      kubelet, minikube  Successfully pulled image "smart48/smt-nginx:latest"
  Normal  Created    9m12s      kubelet, minikube  Created container nginx
  Normal  Started    9m12s      kubelet, minikube  Started container nginx
```

## Issues with old pods

```
kubectl get po --all-namespaces
NAMESPACE              NAME                                             READY   STATUS             RESTARTS   AGE
default                web-64c5bc5fdf-4kp58                             0/2     ImagePullBackOff   0          2m42s
default                web-64c5bc5fdf-fl8jb                             0/2     ImagePullBackOff   0          2m42s
default                web-64c5bc5fdf-mdlw6                             0/2     ImagePullBackOff   0          2m42s
kube-system            coredns-6955765f44-9k4nn                         1/1     Running            6          119d
kube-system            coredns-6955765f44-zp2qr                         1/1     Running            6          119d
kube-system            etcd-minikube                                    1/1     Running            6          119d
kube-system            kube-apiserver-minikube                          1/1     Running            6          119d
kube-system            kube-controller-manager-minikube                 1/1     Running            6          119d
kube-system            kube-proxy-qrzc5                                 1/1     Running            6          119d
kube-system            kube-scheduler-minikube                          1/1     Running            6          119d
kube-system            nginx-ingress-controller-6fc5bcc8c9-f72c8        1/1     Running            3          113d
kube-system            storage-provisioner                              1/1     Running            9          119d
kubernetes-dashboard   dashboard-metrics-scraper-7b64584c5c-lhfk6       1/1     Running            2          113d
kubernetes-dashboard   kubernetes-dashboard-79d9cd965-gpgzb             1/1     Running            4          113d
laravel6               cert-manager-7974f4ddf4-gkz58                    1/1     Running            4          119d
laravel6               cert-manager-cainjector-76f7596c4-v8n6c          1/1     Running            8          119d
laravel6               cert-manager-webhook-8575f88c85-j2sdm            1/1     Running            4          119d
laravel6               nginx-ingress-controller-69d5dc598f-zfpwd        1/1     Running            8          119d
laravel6               nginx-ingress-default-backend-659bd647bd-568kb   1/1     Running            4          119d
```

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

### Load Balancer

_If you want to directly expose a service, this is the default method. All traffic on the port you specify will be forwarded to the service. There is no filtering, no routing, etc. This means you can send almost any kind of traffic to it, like HTTP, TCP, UDP, Websockets, gRPC, or whatever._

### Nginx Ingress

Nginx Ingress can do all a load balancer can and more. It is not a service but a router routing to services which could be separate nginx services representing CNAMES or ANAMEs

To run it on minikube use `minikube addons enable ingress`

_Unlike all the above examples, Ingress is actually NOT a type of service. Instead, it sits in front of multiple services and act as a “smart router” or entrypoint into your cluster._

_DigitalOcean block storage is only mounted to a single node, so you will set the accessModes to ReadWriteOnce._

_Kubernetes Ingresses allow you to flexibly route traffic from outside your Kubernetes cluster to Services inside of your cluster. This is accomplished using Ingress Resources, which define rules for routing HTTP and HTTPS traffic to Kubernetes Services, and Ingress Controllers, which implement the rules by load balancing traffic and routing it to the appropriate backend Services._

Normally an Nginx Ingress deployment on Digital Ocean can be done with `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/do/deploy.yaml` We however set this up in provisioning package.

[node ports, load balancers and nginx ingress](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0)
[do ingress setup](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes#step-1-%E2%80%94-setting-up-dummy-backend-services)
[Nginx Ingress Deploy](https://kubernetes.github.io/ingress-nginx/deploy/)

### Read Write Many Setup with NFS Sserver

A[Read Write Many Setup at DO](https://www.digitalocean.com/community/tutorials/how-to-set-up-readwritemany-rwx-persistent-volumes-with-nfs-on-digitalocean-kubernetes) is possible with an NFS server so you can share data across Droplets or Nodes. This setup is not used in our current deployment.

_DigitalOcean’s default Block Storage CSI solution is unable to support mounting one block storage volume to many Droplets simultaneously. This means that this is a ReadWriteOnce (RWO) solution, since the volume is confined to one node. The Network File System (NFS) protocol, on the other hand, does support exporting the same share to many consumers. This is called ReadWriteMany (RWX), because many nodes can mount the volume as read-write. We can therefore use an NFS server within our cluster to provide storage that can leverage the reliable backing of DigitalOcean Block Storage with the flexibility of NFS shares._

## Queues and Schedule

_Queues allow you to defer the processing of a time consuming task, such as sending an email, until a later time._

_In the past, you may have generated a Cron entry for each task you needed to schedule on your server. However, this can quickly become a pain, because your task schedule is no longer in source control and you must SSH into your server to add additional Cron entries. Laravel's command scheduler allows you to fluently and expressively define your command schedule within Laravel itself._

## Deployment issues

```
kubectl apply -f deployments/web.yml
error: error validating "deployments/web.yml": error validating data: [ValidationError(Deployment.spec.template.spec.containers[0]): unknown field "initContainers" in io.k8s.api.core.v1.Container, ValidationError(Deployment.spec.template.spec.containers[3].lifecycle): unknown field "exec" in io.k8s.api.core.v1.Lifecycle]; if you choose to ignore these errors, turn validation off with --validate=false
```


## Minikube Ingress issues


```
minikube addons enable ingress
💡  Due to docker networking limitations on darwin, ingress addon is not supported for this driver.
Alternatively to use this addon you can use a vm-based driver:

  'minikube start --vm=true'

To track the update on this work in progress feature please check:
https://github.com/kubernetes/minikube/issues/7332
```

This

```
minikube config set vm-driver hyperkit
minikube delete
minikube start
minikube addons enable ingress
```

Found https://github.com/kubernetes/minikube/issues/2456#issuecomment-446905595 :

```
nano /usr/local/etc/dnsmasq.conf
```
and add

```
server=/kube.local/192.168.64.1
listen-address=127.0.0.1,192.168.64.1
```

and `valet restart` and then there are nginx , php and dsnmasq errors. It needed

`sudo /etc/resolver/local`

with the addtion of
```
port 5354
nameserver 127.0.0.1
```

and a total restart of dnsmasq. Only now dnsmaq, nginx and php are running as root which is not ideal.

This solution failed again as well.

Then I added

```
server=/kube.local/192.168.64.1
listen-address=127.0.0.1,192.168.64.1
```

and ran

```
sudo launchctl stop homebrew.mxcl.dnsmasq
sudo launchctl start homebrew.mxcl.dnsmasq
```


And then I checked

```
brew services list
Name    Status  User   Plist
dnsmasq started root   /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
httpd   stopped
mariadb started jasper /Users/jasper/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
nginx   error   root   /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
php     started root   /Library/LaunchDaemons/homebrew.mxcl.php.plist
redis   started jasper /Users/jasper/Library/LaunchAgents/homebrew.mxcl.redis.plist
➜  ~ sudo brew services list
Name    Status  User Plist
dnsmasq started root /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
httpd   stopped
mariadb started root /Users/jasper/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
nginx   started root /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
php     error   root /Library/LaunchDaemons/homebrew.mxcl.php.plist
redis   started root /Users/jasper/Library/LaunchAgents/homebrew.mxcl.redis.plist
```

When I tried Chrome and Safari Laravel Valet was still working. And.. in Brave also. So did a minikube restart:


```
➜  smt-deploy git:(main) ✗ minikube stop   
✋  Stopping "minikube" in hyperkit ...
🛑  Node "minikube" stopped.
➜  smt-deploy git:(main) ✗ minikube start  
😄  minikube v1.11.0 on Darwin 10.15.7
✨  Using the hyperkit driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
🔄  Restarting existing hyperkit VM for "minikube" ...
🐳  Preparing Kubernetes v1.18.3 on Docker 19.03.8 ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: default-storageclass, ingress, storage-provisioner
🏄  Done! kubectl is now configured to use "minikube"
```

## Check Deployments  & Pods
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


## Minikube Post Upgrade issues

We updated Minikube to latest to work with Kubernetes 1.19.x... only to realize only 1.18.3 was added. However here an fyi. Post `brew upgrade minikube` you may need to use :

```
brew link minikube
```

to fire off commands again.

They did however mention _Kubernetes 1.19.4 is now available. If you would like to upgrade, specify: --kubernetes-version=v1.19.4_

So we did:

```
minikube start --kubernetes-version=v1.19.4😄  minikube v1.15.1 on Darwin 10.15.7
✨  Using the hyperkit driver based on existing profile
👍  Starting control plane node minikube in cluster minikube
💾  Downloading Kubernetes v1.19.4 preload ...
    > preloaded-images-k8s-v6-v1.19.4-docker-overlay2-amd64.tar.lz4: 59.73 MiB 
...
```

**NB** The `~/.zshrc ` tweaks to work with autocomplete https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh :

```
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi
```

may not be necessary


## PV Issues

```
kubectl apply -f local/storage/pv.yml
The PersistentVolume "code-pv" is invalid: 
* spec.accessModes: Required value
* spec.capacity: Required value
* spec.capacity: Unsupported value: core.ResourceList(nil): supported values: "storage"
* spec: Required value: must specify a volume type
```

Needed different setup altogether. See https://github.com/kubernetes/minikube/issues/214 


## Remove PVCS

https://medium.com/@miyurz/kubernetes-deleting-resource-like-pv-with-force-and-grace-period-0-still-keeps-pvs-in-3f4ad8710e51


To delete pvcs forcefully `--force`:

```
kubectl delete pv --all -n smt-local --force 
```
often does not work. You also need

```
kubectl edit persistentvolume/pvc-521d9a78-dba4–11e8-b576–12241a2479c2
```

and then remove the 

```
finalizers:
  -  kubernetes.io/pv-protection
  and second line here
```

This kind of removals you should of course not do lightly.

## Minikube Ingress Deprecated Warning Post Upgrade

When checking Ingress resources with locally enabled Ingress Nginx we are getting

```
kubectl get ingress -n smt-local
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
```

When you add api version v1 all is well

```
smt-deploy git:(main) ✗ kubectl get ingresses.v1.networking.k8s.io -n smt-local
NAME               CLASS    HOSTS            ADDRESS        PORTS   AGE
ingress-resource   <none>   smart48k8.test   192.168.64.5   80      21h
```

## On Pods

Seems we should in general create deployments and not naked pods so will keep it that way

https://kubernetes.io/docs/concepts/configuration/overview/#naked-pods-vs-replicasets-deployments-and-jobs


_A Deployment, which both creates a ReplicaSet to ensure that the desired number of Pods is always available, and specifies a strategy to replace Pods (such as RollingUpdate), is almost always preferable to creating Pods directly, except for some explicit restartPolicy: Never scenarios. A Job may also be appropriate._

## Local Mount Point

resources
- https://minikube.sigs.k8s.io/docs/handbook/mount/
- https://minikube.sigs.k8s.io/docs/handbook/persistent_volumes/

When mounting a directory it seems you cannot just work in the same shell as the process needs to stay alive

```
minikube mount $HOME/code/smt-data:/data
📁  Mounting host path /Users/jasper/code/smt-data into VM as /data ...
    ▪ Mount type:   
    ▪ User ID:      docker
    ▪ Group ID:     docker
    ▪ Version:      9p2000.L
    ▪ Message Size: 262144
    ▪ Permissions:  755 (-rwxr-xr-x)
    ▪ Options:      map[]
    ▪ Bind Address: 192.168.64.1:58725
🚀  Userspace file server: ufs starting
✅  Successfully mounted /Users/jasper/code/smt-data to /data

📌  NOTE: This process must stay alive for the mount to be accessible ...
```

Seems something like `$ minikube start --mount-string="$HOME/go/src/github.com/nginx:/data"` at the beginning is better.

see https://stackoverflow.com/questions/48534980/mount-local-directory-into-pod-in-minikube#48535001


### Mount Point Post Minikube start


**NB** Only use this part if you did not start Minikube with a directory already mounted!

resources:
- https://minikube.sigs.k8s.io/docs/handbook/mount/
- https://stackoverflow.com/questions/54993532/how-to-use-kubernetes-persistent-local-volumes-with-minikube-on-osx
- https://stackoverflow.com/questions/48534980/mount-local-directory-into-pod-in-minikube#48535001

You need to mount a host based directory of choice in the Minikube Virtual Box. One you refer to when you use PVs and mount data. So we made a new data directory on the macOS host and connected it to the data directory on the Minikube Virtual Box:

```
mkdir -p $HOME/code/smt-data
minikube mount $HOME/code/smt-data:/data
```

This will load data from your host inside `~/code/smt-code` as `/data` on the virtual host. This way however you need to keep the process running


## Minikube Directory Creation

For working with `hostPath` you need to create directories in the VM it seems. Now mainly focussing on non hostPath setup

```
1   cd /data/
2   ls -la
8   sudo mkdir code
9   ls -la
15  sudo chown docker:docker code/
16  sudo mkdir mysql
17  sudo mkdir redis
18  sudo chown docker:docker redis/
19  sudo chown docker:docker mysql/
24  sudo mkdir nginx
26  chown docker:docker nginx/
27  sudo chown docker:docker nginx/
28  cd nginx/
```

## Debugging CrashLoopBackOff


To debug CrashLoopBackOff you need to check the pod's log instead of minikube to get to the bottom of things:

```
kubectl logs -f app-5779b848cb-2srl6 
error: a container name must be specified for pod app-5779b848cb-2srl6, choose one of: [laravel nginx laravel-horizon mysql]
➜  smt-deploy git:(main) ✗ kubectl logs -f app-5779b848cb-2srl6 laravel
[07-Dec-2020 05:02:52] NOTICE: fpm is running, pid 1
[07-Dec-2020 05:02:52] NOTICE: ready to handle connections
^C
➜  smt-deploy git:(main) ✗ kubectl logs -f app-5779b848cb-2srl6 nginx  
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
^C
➜  smt-deploy git:(main) ✗ kubectl logs -f app-5779b848cb-2srl6 laravel-horizon 
Could not open input file: artisan
➜  smt-deploy git:(main) ✗ kubectl logs -f app-5779b848cb-2srl6 mysql          
2020-12-07 05:09:45+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.22-1debian10 started.
2020-12-07 05:09:45+00:00 [Note] [Entrypoint]: Switching to dedicated user 'mysql'
2020-12-07 05:09:45+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.22-1debian10 started.
2020-12-07 05:09:45+00:00 [ERROR] [Entrypoint]: Database is uninitialized and password option is not specified
You need to specify one of MYSQL_ROOT_PASSWORD, MYSQL_ALLOW_EMPTY_PASSWORD and MYSQL_RANDOM_ROOT_PASSWORD
```

If you do try to enter one of these containers with issues you will fail:

```
kubectl exec -it app-5779b848cb-2srl6 -c mysql -- /bin/bash
error: unable to upgrade connection: container not found ("mysql")
```

## Docker Hub Rate Limiting Snag

Seems I have been pulling too often and I need to upgrade to not hit the rate limiting .

```
Warning  Failed     19s               kubelet            Failed to pull image "smart48/smt-mysql:latest": rpc error: code = Unknown desc = Error response from daemon: toomanyrequests: You have reached your pull rate limit. You may increase the limit by authenticating and upgrading: https://www.docker.com/increase-rate-limit
```

## Password encoding

Linux

```
echo -n "root" | base64
```

macOs

```
mac echo -n 'root' | openssl base64
```

## Ingress Issues

```
kubectl logs -f pod/ingress-nginx-controller-558664778f-8mw9f -n kube-system
```


and you could see something like this where it shows there is a 503 and no endpoints

```
W1214 09:15:02.081958       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 09:23:09.085274       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 09:30:53.087830       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 09:40:00.091440       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 09:47:36.094829       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 09:54:10.096519       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:03:22.099057       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:13:14.101710       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:18:42.103631       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:25:03.105804       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:32:53.107958       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:41:15.110221       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:50:17.112228       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 10:58:53.116279       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
192.168.64.1 - - [14/Dec/2020:11:07:02 +0000] "GET / HTTP/1.1" 503 190 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15" 357 0.000 [smt-local-nginx-8080] [] - - - - c0a25f0592e036fc43cd6493b5d61878
W1214 11:07:17.118076       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W1214 11:11:46.559640       7 controller.go:937] Service "smt-local/nginx" does not have any active Endpoint.
W1214 11:11:49.892977       7 controller.go:937] Service "smt-local/nginx" does not have any active Endpoint.
W1214 11:11:53.226835       7 controller.go:937] Service "smt-local/nginx" does not have any active Endpoint.
W1214 11:11:56.560180       7 controller.go:937] Service "smt-local/nginx" does not have any active Endpoint.
W1214 11:14:26.120896       7 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
192.168.64.1 - - [14/Dec/2020:11:15:30 +0000] "GET / HTTP/1.1" 503 190 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15" 357 0.000 [smt-local-nginx-8080] [] - - - - 2121620296b56907c2aaef83e9904185
```

## Label Selector Immutable

https://stackoverflow.com/a/58909680/460885

_Note: In API version apps/v1, a Deployment’s label selector is immutable after it gets created._

```
The Deployment "nginx" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app":"nginx", "tier":"backend"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
➜  smt-deploy git:(main) ✗ kubectl delete deployments.apps nginx       
deployment.apps "nginx" deleted
➜  smt-deploy git:(main) ✗ kubectl apply -f local/deployments/nginx.yml
deployment.apps/nginx created
```

then newly setup labels got applied and endpoint started to work

```
kubectl get endpoints                                                       
NAME    ENDPOINTS         AGE
nginx   172.17.0.5:8080   5h50m
php     <none>            5h50m
```

## Connection refused upstream

```
192.168.64.1 - - [14/Dec/2020:12:38:11 +0000] "GET / HTTP/1.1" 502 150 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.1 Safari/605.1.15" 357 0.001 [smt-local-nginx-8080] [] 172.17.0.5:8080, 172.17.0.5:8080, 172.17.0.5:8080 0, 0, 0 0.001, 0.000, 0.000 502, 502, 502 3996d026304a894ccf59c04b7c6bffb3
2020/12/14 12:38:11 [error] 280#280: *130058 connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.64.1, server: smart48k8.local, request: "GET / HTTP/1.1", upstream: "http://172.17.0.5:8080/", host: "smart48k8.local"
2020/12/14 12:38:11 [error] 280#280: *130058 connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.64.1, server: smart48k8.local, request: "GET / HTTP/1.1", upstream: "http://172.17.0.5:8080/", host: "smart48k8.local"
2020/12/14 12:38:11 [error] 280#280: *130058 connect() failed (111: Connection refused) while connecting to upstream, client: 192.168.64.1, server: smart48k8.local, request: "GET / HTTP/1.1", upstream: "http://172.17.0.5:8080/", host: "smart48k8.local"
```