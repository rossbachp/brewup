# Kind with cilium

- https://docs.cilium.io/en/stable/installation/kind/
- https://kind.sigs.k8s.io
- https://maelvls.dev/docker-proxy-registry-kind/
  - Kind with registries mirror
  - More registries proxies: https://github.com/rpardini/docker-registry-proxy
- https://medium.com/@charled.breteche/kind-cluster-with-cilium-and-no-kube-proxy-c6f4d84b5a9d

```shell
task kind
cilium connectivity test
# review mirrors
docker exec -it kind-control-plane cat /etc/containerd/config.toml

```

TODO: 

```shell
- sed -i "s/cgroupDriver: systemd/cgroupDriver: cgroupfs/g" /var/lib/kubelet/config.yaml

  kubeadmConfigPatches:
  - |
    kind: KubeletConfiguration
    apiVersion: kubelet.config.k8s.io/v1beta1
    cgroupDriver: cgroupfs
  labels:
    node-role.kubernetes.io/worker=
```

## debug

```shell
docker exec -it cnbc-homelab-control-plane /bin/bash
ctr -n k8s.io image ls
crictl pods
curl host.docker.internal:5002/v2/_catalog
{"repositories":[]}
```

## Licensing

Copyright (c) 2024 Peter Rossbach <peter.rossbach@bee42.com>

MIT License, see [LICENSE.txt](../../../LICENSE.txt) for more details.

Regards,

[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
