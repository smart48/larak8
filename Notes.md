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