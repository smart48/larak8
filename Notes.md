# Notes


Notes on issues encountered setting up this deployment.

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