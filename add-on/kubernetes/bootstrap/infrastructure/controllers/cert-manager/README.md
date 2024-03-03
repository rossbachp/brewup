# Cert manager

* https://artifacthub.io/packages/helm/cert-manager/cert-manager
* https://github.com/k3s-io/helm-controller

## Manualy install cert manager

```shell
VERSION=1.13.3
k create namespace cert-manager
# we need to install the certificate types in order for the cert manager to 
# actually interpret the certificate files correctly
k -n cert-manager apply -f \
  https://github.com/cert-manager/cert-manager/releases/download/v$VERSION/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v$VERSION
k -n cert-manager get pod
```

Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
