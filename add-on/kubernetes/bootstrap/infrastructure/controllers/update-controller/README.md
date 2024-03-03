# update controller

- https://github.com/rancher/system-upgrade-controller/blob/master/README.md
- https://hub.docker.com/r/rancher/k3s-upgrade
- https://hub.docker.com/r/rancher/k3s
- https://github.com/rancher/kubectl/tree/master/package
- [bitnami/kubectl:latest](https://github.com/bitnami/containers/tree/main/bitnami/kubectl)
  - https://hub.docker.com/r/bitnami/kubectl/tags?page=1&name=1.29

```shell
#kustomize build github.com/rancher/system-upgrade-controller | kubectl apply -f - 
# download
curl -sLO https://github.com/rancher/system-upgrade-controller/releases/download/v0.4.0/system-upgrade-controller.yaml
sed "s/  SYSTEM_UPGRADE_JOB_KUBECTL_IMAGE: rancher\/kubectl:v1\.17\.0/. SYSTEM_UPGRADE_JOB_KUBECTL_IMAGE: rancher\/kubectl:v1\.29\.1/g" \
system-upgrade-controller.yaml | kubectl apply -f -

```

```shell
k apply -f k3s-upgrade.yaml
k label node k3d-homelab-server-0 k3s-upgrade=true
k label node k3d-homelab-agent-0 k3s-upgrade=true
k label node k3d-homelab-agent-1 k3s-upgrade=true
k get nodes -w
```

kubectl get ciliumnodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.ipam.operator-status}{"\n"}{end}'


Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)