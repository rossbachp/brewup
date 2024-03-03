# Bootstrap your CNBC Kubernetes Smart GitOps Runtime

Preparations:

- Prepare your local ssh git server (add-on cnbc services)
- Create a Kubernetes cluster with k3d (see install k3d cluster with cilium CNI)

Bootstrap Your CNBC Smart GitOps Runtime:

- Bootstrap fluxcd inside your cluster
- Check out your environmet repo cnbc-homelab
- Choose your infrastructure components
- checkin and wait that flux do the job
- Have fun with the services

## Bootstrap fluxcd inside your cluster

```shell
#export GIT_SSH_COMMAND="/usr/bin/ssh -o StrictHostKeyChecking=yes -i ~/develop/brewup/add-on/cnbc/ssh/id_cnbc-dev-sync-rsa"
cd $HOME
#INTERFACE=enp0s2
#INTERFACE=INTERFACE=enp1s0f
#YOUR_GIT_HOST=$(/sbin/ip -o -4 addr list $INTERFACE | awk '{print $4}' | cut -d/ -f1)
YOUR_GIT_HOST=host.k3d.internal
docker image tag bee42/git-ssh:latest cnbc-registry:5003/bee42/git-ssh
docker image push cnbc-registry:5003/bee42/git-ssh
kubectl run --rm -it ssh-keyscan --image cnbc-registry:5003/bee42/git-ssh \
  -- /bin/sh -c "/usr/bin/ssh-keyscan -p 2222 $YOUR_GIT_HOST" \
  >>~/develop/brewup/add-on/cnbc/ssh/known_hosts

eval `ssh-agent -s`
ssh-add ~/develop/brewup/add-on/ssh/id_cnbc-dev-sync-rsa

flux check --pre
flux bootstrap git \
  --url=ssh://git@${YOUR_GIT_HOST}:2222/srv/git/cnbc-dev.git \
  --private-key-file=$HOME/develop/brewup/add-on/cnbc/ssh/id_cnbc-dev-sync-rsa \
  --ssh-hostname=${YOUR_GIT_HOST} \
  --ssh-key-algorithm=rsa \
  --ssh-rsa-bits=4096 \
  --branch=main \
  --path=clusters/cnbc-homelab
flux check
```

## Check out your environmet repo cnbc-homelab

- [flux2-kustomize-helm-example](https://github.com/fluxcd/flux2-kustomize-helm-example)

```shell
mkdir -p ~/develop/brewup/add-on/kubernetes/environments
cd ~/develop/brewup/add-on/kubernetes/environments
export GIT_SSH_COMMAND="/usr/bin/ssh -o StrictHostKeyChecking=yes -i ~/develop/brewup/add-on/cnbc/ssh/id_cnbc-dev-sync-rsa"
git clone --depth 1 ssh://git@127.0.0.1:2222/srv/git/cnbc-dev.git
cd cnbc-dev.git
mkdir -p infrastructures/base/coredns
cp -r ../../bootstrap/infrastructures/base/coredns infrastructures/base/coredns
```