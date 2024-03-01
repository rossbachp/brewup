# Create k3d kubernetes cluster

```shell
k3d cluster create cnbc-homelab \
  --agents-memory 4Gi \
  --servers-memory 2Gi \
  --config $(pwd)/cnbc-homelab.yaml
```
