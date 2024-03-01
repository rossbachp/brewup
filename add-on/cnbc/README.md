# Create Git Server

```shell
cd ~/develop/brewup/add-on/cnbc
docker compose up -d git
mkdir -p ssh
ssh-keygen -t rsa -b 4096 -N "" -f ssh/id_cnbc-dev-sync-rsa
cat ssh/id_cnbc-dev-sync-rsa.pub >>ssh/authorized_keys

# create tool
docker build -t bee42/git-ssh .
docker container run --rm -v $(pwd)/ssh:/root/ssh bee42/git-ssh \
  ssh-keyscan -p 2222 host.docker.internal >>ssh/known_hosts

ssh-keyscan -p 2222 127.0.0.1 >>~/.ssh/known_hosts

# create manually the git repo
ssh git@127.0.0.1 -i ssh/id_cnbc-dev-sync-rsa -p 2222
# pwd see your .env
mkdir /srv/git/cnbc-dev.git
git-init --bare /srv/git/cnbc-dev.git
exit

# check creds to access repo from flux2
# https://www.git-tower.com/learn/git/faq/git-rename-master-to-main
docker container run --rm -it -v $(pwd)/ssh:/root/.ssh \
  -e GIT_SSH_COMMAND="/usr/bin/ssh -o StrictHostKeyChecking=yes -i /root/.ssh/id_cnbc-dev-sync-rsa" \
  --workdir /root bee42/git-ssh  /bin/sh
git config --global user.email "peter.rossbach@bee42.com"
git config --global user.name "Peter Rossbach"
git config --global init.defaultBranch main
git clone ssh://git@host.docker.internal:2222/srv/git/cnbc-dev.git
cd cnbc-dev
git status
# master***
echo "# Flux Repo" >README.md

git add .
git commit -sm "Inital checkin"
git push
exit
```

Access with git at host with

```shell
ssh-keyscan -p 2222 127.0.0.1 >>~/develop/brewup/add-on/ssh/known_hosts
export GIT_SSH_COMMAND="/usr/bin/ssh -o StrictHostKeyChecking=yes -i ~/develop/brewup/add-on/ssh/id_cnbc-dev-sync-rsa"
git clone ssh://git@127.0.0.1:2222/srv/git/cnbc-git.git
```

Regards,
[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
