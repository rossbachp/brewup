# Create k3d local kubernetes cluster

## CNI Provider Cilium:

I review this references to get my exyample up and running. Many thanks to share this with me.

- [Cilium](https://cilium.io)
  - https://www.edvpfau.de/kubernetes-k3d-mit-cilium-und-hubble/
  - https://blog.stonegarden.dev/articles/2024/02/bootstrapping-k3s-with-cilium/
  - https://github.com/cilium/cilium/issues/18675
  - https://docs.cilium.io/en/stable/operations/system_requirements/#linux-kernel
  - https://sandstorm.de/de/blog/post/running-cilium-in-k3s-and-k3d-lightweight-kubernetes-on-mac-os-for-development.html
  - https://blogops.mixinet.net/posts/testing_cilium_with_k3d_and_kind/
  - https://docs.cilium.io/en/stable/network/kubernetes/kubeproxy-free/#nodeport-devices

## Create Cluster with k3d

- [K3d](https://k3d.io/)
- [Check K3S images](https://hub.docker.com/r/rancher/k3s/tags?page=1&name=1.29)
- [K3s server cli args](https://docs.k3s.io/cli/server)

```shell
CLUSTERNAME=cnbc-homelab

# Create your own network
docker network create \
  --driver=bridge \
  --subnet=172.29.0.0/24 \
  --ip-range=172.29.0.0/25 \
  --gateway=172.29.0.1 \
  $CLUSTERNAME

k3d cluster create $CLUSTERNAME \
  --agents-memory 4Gb \
  --servers-memory 2Gb \
  --config $(pwd)/cnbc-homelab.yaml

# Now I add this to k3d-entrypoint-clilum.sh t every node before cilium agent starts :)
# prepare the k3d container nodes for eBPF usage
CLUSTERNAME=cnbc-homelab
CLUSTERWORKER=2
for AGENT in $(seq 0 ${CLUSTERWORKER+1} 1)
do
  echo k3d-$CLUSTERNAME-agent-$AGENT
  docker exec -it k3d-$CLUSTERNAME-agent-$AGENT mount bpffs /sys/fs/bpf -t bpf
  docker exec -it k3d-$CLUSTERNAME-agent-$AGENT mount --make-shared /sys/fs/bpf
  docker exec -it k3d-$CLUSTERNAME-agent-$AGENT mkdir -p /run/cilium/cgroupv2
  docker exec -it k3d-$CLUSTERNAME-agent-$AGENT mount -t cgroup2 none /run/cilium/cgroupv2
  docker exec -it k3d-$CLUSTERNAME-agent-$AGENT mount --make-shared /run/cilium/cgroupv2
done

docker exec -it k3d-$CLUSTERNAME-server-0 mount bpffs /sys/fs/bpf -t bpf
docker exec -it k3d-$CLUSTERNAME-server-0 mount --make-shared /sys/fs/bpf
docker exec -it k3d-$CLUSTERNAME-server-0 mkdir -p /run/cilium/cgroupv2
docker exec -it k3d-$CLUSTERNAME-server-0 mount -t cgroup2 none /run/cilium/cgroupv2
docker exec -it k3d-$CLUSTERNAME-server-0 mount --make-shared /run/cilium/cgroupv2

# IP from k3d server node
API_SERVER_IP=$(docker container inspect k3d-$CLUSTERNAME-server-0 --format json | jq -r ".[].NetworkSettings.Networks.\"$CLUSTERNAME\".IPAddress")
echo $API_SERVER_IP
172.29.0.3
API_SERVER_PORT=6443
# https://docs.cilium.io/en/stable/network/concepts/ipam/kubernetes/
# kubernetes IPAM per agent/node/minion 10.42.0.0/24
# https://github.com/cilium/cilium/blob/main/install/kubernetes/cilium/values.yaml
# review charts values

CLUSTER_CIDR=10.43.0.0/16
helm repo add cilium https://helm.cilium.io/
helm upgrade --install cilium cilium/cilium --version 1.15.1 \
  --namespace kube-system \
  --set k8sServiceHost=${API_SERVER_IP} \
  --set k8sServicePort=${API_SERVER_PORT} \
  --set ipv4NativeRoutingCIDR=${CLUSTER_CIDR} \
  --values values-cilium.yaml
    
# or use the cilium cli!
cilium install \
  --set k8sServiceHost=${API_SERVER_IP} \
  --set k8sServicePort=${API_SERVER_PORT} \
  --set ipv4NativeRoutingCIDR=${CLUSTER_CIDR} \
  --values values-cilium.yaml \
  --version 1.15.1
# check status of deployment
# needs time >2 minutes
k get pods -A -w
cilium status --wait
```

## Define a Policy

- https://docs.cilium.io/en/latest/network/l2-announcements/

```shell
cat >ipam.yaml <<EOF
apiVersion: "cilium.io/v2alpha1"
kind: CiliumLoadBalancerIPPool
metadata:
  name: "blue-pool"
spec:
  blocks:
  - cidr: "$(echo "${API_SERVER_IP}" | awk -F "." '{ printf "%s.%s.%s.128/28", $1,$2,$3 }')"
---
apiVersion: "cilium.io/v2alpha1"
kind: CiliumL2AnnouncementPolicy
metadata:
  name: ingress
spec:
  serviceSelector:
    matchLabels:
      cilium.io/ingress: "true"
  nodeSelector:
    matchExpressions:
    - key: node-role.kubernetes.io/control-plane
      operator: DoesNotExist
  interfaces:
  - ^eth[0-9]+
  #  externalIPs: true
  loadBalancerIPs: true
EOF
k apply -f ipam.yaml
k get l2announcement
NAME      AGE
ingress   18s
cilium connectivity test
# a lot errors...
```


## Start a nginx example service

```shell
# check ingress LB IP
k get svc -A
k get ingressclasses

# create services
k create namespace nginx
k ns nginx
k run nginx --image nginx --expose --port 80
k run curl --image curlimages/curl --rm=true -it -- /bin/sh
curl nginx
exit
k create ingress nginx --class=cilium --rule="nginx.cnbc-homelab.bee42.io/*=nginx:80"
k get ingress
# Sorry but the LB-IP 172.29-129 doesn't answer!!! You know why, oelase send me email or report a pullrequest
curl --resolve "nginx.cnbc-homelab.bee42.io:80:172.29.0.129" http://nginx.cnbc-homelab.bee42.io

# Service IP is available but ingress made problems
curl -H "Host: nginx.cnbc-homelab.bee42.io"  -v http://172.29.0.129
*   Trying 172.29.0.129:80...
* Connected to 172.29.0.129 (172.29.0.129) port 80
> GET / HTTP/1.1
> Host: nginx.cnbc-homelab.bee42.io
> User-Agent: curl/8.4.0
> Accept: */*
> 
< HTTP/1.1 503 Service Unavailable
< content-length: 91
< content-type: text/plain
< date: Sun, 03 Mar 2024 13:07:12 GMT
< server: envoy
< 
* Connection #0 to host 172.29.0.129 left intact

# inside the net
docker run -it --rm --network container:k3d-cnbc-homelab-agent-1 curlimages/curl /bin/sh
curl -v -s --resolve "nginx.cnbc-homelab.bee42.io:80:172.29.0.129" http://nginx.cnbc-homelab.bee42.io
# you can see the ARP entry but noting is forwared..
arp -a
? (172.29.0.1) at 02:42:55:89:81:e9 [ether]  on eth0
? (10.42.1.159) at 6a:df:51:2b:40:69 [ether]  on lxcaba2882b0034
k3d-cnbc-homelab-agent-0.cnbc-homelab (172.29.0.5) at 02:42:ac:1d:00:05 [ether]  on eth0
? (10.42.1.1) at 3a:e1:88:80:9e:87 [ether]  on lxc41db9546bdf3
? (10.42.1.173) at b6:20:3f:7e:c0:83 [ether]  on lxc2eb2ef3f1cfd
? (172.29.0.129) at 02:42:ac:1d:00:05 [ether]  on eth0
? (10.42.1.219) at 9e:45:65:a6:88:be [ether]  on lxc_health
k3d-cnbc-homelab-server-0.cnbc-homelab (172.29.0.3) at 02:42:ac:1d:00:03 [ether]  on eth0
? (10.42.1.119) at 1e:a2:0f:43:94:66 [ether]  on lxce45c82971043
```


hubble

```shell
cilium hubble port-forward&
hubble status
hubble observe
curl -v -s --resolve "nginx.cnbc-homelab.bee42.io:80:172.29.0.129" http://nginx.cnbc-homelab.bee42.io
curl -v -s -H "Host: nginx.cnbc-homelab.bee42.io" http://172.29.0.129 
hubble observe --pod nginx --protocol http
hubble observe --from-service kube-system/cilium-ingress --protocol http
Mar  3 15:45:52.752: 172.29.0.1:64231 (ingress) <- kube-system/cilium-ingress:80 (world) http-response FORWARDED (HTTP/1.1 503 5001ms (GET http://nginx.cnbc-homelab.bee42.io/))
Mar  3 15:47:40.563: 172.29.0.1:64255 (ingress) <- kube-system/cilium-ingress:80 (world) http-response FORWARDED (HTTP/1.1 503 5002ms (GET http://nginx.cnbc-homelab.bee42.io/))
hubble observe --from-service nginx/nginx
# empty
k get ingress
NAME    CLASS    HOSTS                         ADDRESS        PORTS   AGE
nginx   cilium   nginx.cnbc-homelab.bee42.io   172.29.0.129   80      24h
hubble observe --pod nginx --verdict DROPPED
```

## Bootstrap infrastructure services

- https://byby.dev/bash-exit-codes#:~:text=The%20special%20shell%20variable%20%24%3F%20in%20bash%20is%20used%20to,actions%20based%20on%20the%20result.
- Taskfile

```shell
task cnbc
```

## Teardown the cluster

```shell
k3d cluster delete cnbc-homelab
```


## Licensing

Copyright (c) 2024 Peter Rossbach <peter.rossbach@bee42.com>

MIT License, see [LICENSE.txt](../../../LICENSE.txt) for more details.

Regards,

[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
