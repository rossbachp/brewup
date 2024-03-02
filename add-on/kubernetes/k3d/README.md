# Create k3d local kubernetes cluster

## CNI Provider Cilium:

- [Cilium](https://cilium.io)
  - https://www.edvpfau.de/kubernetes-k3d-mit-cilium-und-hubble/
  - https://blog.stonegarden.dev/articles/2024/02/bootstrapping-k3s-with-cilium/
  - https://github.com/cilium/cilium/issues/18675
  
## Create Cluster with k3d

- [K3d](https://k3d.io/)
- [Check K3S images](https://hub.docker.com/r/rancher/k3s/tags?page=1&name=1.29)

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
EOF
k apply -f ipam.yaml
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
```

## Bootstrap infrastructure services

## Teardown the cluster

```shell
k3d cluster delete cnbc-homelab
```

## Licensing

Copyright (c) 2024 Peter Rossbach <peter.rossbach@bee42.com>

MIT License, see [LICENSE.txt](../../../LICENSE.txt) for more details.

Regards,

[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
