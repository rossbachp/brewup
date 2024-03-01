# Create k3d kubernetes cluster

```shell
k3d cluster create cnbc-homelab \
  --agents-memory 4Gb \
  --servers-memory 2Gb \
  --config $(pwd)/cnbc-homelab.yaml
```
