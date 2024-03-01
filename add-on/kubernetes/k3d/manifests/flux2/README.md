# fluxcd

* https://fluxcd.io/flux/

## Preparation

macos

```shell
brew install fluxcd/tap/flux
. <(flux completion zsh)
echo 'source <(flux completion zsh)' >>~/.zshrc
```

linux

```shell
curl -s https://fluxcd.io/install.sh | sudo bash
. <(flux completion bash)
echo 'source <(flux completion bash)' >>~/.bashrc
```

## Create manually local git

```shell
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_cnbc-sync-rsa
# without password...
cat ~/.ssh/id_cnbc-sync-rsa.pub >>~/.ssh/authorized_keys
INTERFACE=eth0
YOUR_GIT_HOST=$(/sbin/ip -o -4 addr list $INTERFACE | awk '{print $4}' | cut -d/ -f1)
ssh-keyscan $YOUR_GIT_HOST >/tmp/known_hosts
cat >>~/.ssh/config <<EOF
Host $YOUR_GIT_HOST
    User $USER
    IdentityFile ~/.ssh/id_cnbc-sync-rsa
    IdentitiesOnly yes
    PubkeyAcceptedAlgorithms +ssh-rsa
    HostkeyAlgorithms +ssh-rsa
EOF
```

```shell
sudo apt install -y git

git config --global user.email "peter.rossbach@bee42.com"
git config --global user.name "peter"
git config --global init.defaultBranch main

mkdir ~/fleet_repo.git
cd ~/fleet_repo.git
git --bare init
exit

mkdir -p ~/fluxcd && cd ~/fluxcd
 
export GIT_SSH_COMMAND="/usr/bin/ssh -o StrictHostKeyChecking=yes -i ~/.ssh/id_cnbc-sync-rsa"
 
git clone ${USER}@${YOUR_GIT_HOST}:/home/${USER}/fleet_repo.git
cd ~/fleet_repo
echo "# Start fluxcd" >README.md
git add README.md
git commit -m "Initial checkin"
git push
```

## Install

* With cluster git server

```shell
flux check --pre
k create secert generic ssh-credentials
  --from-file=identiy=../../../cnbc/ssh/id_cnbc-dev-sync-rsa \
  --from-file=known_hosts=../../../cnbc/ssh/known_hosts
k apply -f flux2-config.yaml
k apply -f flux2.yaml
k apply -f cluster.yaml
flux check
```

```shell
YOUR_GIT_HOST=172.20.0.250 
eval `ssh-agent -s`
ssh-add $(pwd)/../../../cnbc/ssh/id_cnbc-dev-sync-rsa
flux check --pre
flux bootstrap git \
  --url ssh://git@host.docker.inernal:2222/srv/git/cnbc-dev.git \
  --private-key-file=$(pwd)/../../../cnbc/id_cnbc-dev-sync-rsa \
  --ssh-hostname=host.docker.inernal \
  --ssh-key-algorithm=rsa \
  --ssh-rsa-bits=4096 \
  --branch=main \
  --path=clusters/dev/cnbc-dev
flux check
```

## create flux gitops structures

```shell
mkdir -p apps/base
mkdir -p infrastructure/base
```

Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
