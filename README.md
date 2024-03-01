# Brew for macOS software management

<img src="images/cnbc-dev.png" alt="cnbc-dev" style="width: 100%;"/>

We use Homebrew a.k.a. brew to install software on our
Cloud Native Base Camp macOS computers.

## Introduction

This repository has our Brew, which manages much of the software that we use for projects.

This Brew helps us install:

- Hundreds of desktop applications, such as browsers, players, editors, etc.
- Hundreds of system utilities, such as command line interfaces, sysop helpers, etc.
- Dozens of programming capabilties, such as languages, toolchains, servers, etc.

To learn about brew and Brewfile capabilties, please see:

- https://brew.sh/
- https://homebrew-file.readthedocs.io/
- https://github.com/Homebrew/homebrew-bundle
- https://github.com/mas-cli/mas

Using a Brew helps us with our Infrastructure as Code (IaC) initiatives.

Feedback welcome. Pull requests welcome.

## Inspired from this repos

- https://github.com/StefanScherer/dotfiles
- https://github.com/paulirish/dotfiles

## brewup your mac with happiness

With the bee42 honeypod brewup installer

- https://github.com/nvm-sh/nvm
- https://github.com/moovweb/gvm
- https://github.com/rupa/z.git
- https://github.com/gmarik/vundle.git
- https://krew.sigs.k8s.io
- https://dagger.io
  - https://dagger.io/blog/introducing-dagger-functions

tmux
- https://hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/
- https://hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/
- https://dev.to/techspresso/tmux-and-vscode-persist-terminals-for-productivity-and-profit-2nd1
- https://pragprog.com/titles/bhtmux2/tmux-2/
- https://github.com/tmux/tmux/wiki
- https://github.com/jonmosco/kube-tmux
- https://arcolinux.com/everything-you-need-to-know-about-tmux-status-bar/
- https://gist.github.com/endersonmaia/3902b94585ef46a9956c0ca9e901cbdf
- https://gist.github.com/dmytro/3984680

  - multiple ssh sessions

```bash
mkdir -p $HOME/.tmux/
cd $HOME/.tmux/
git clone --depth 1 https://github.com/jonmosco/kube-tmux
#curl -sL -o $HOME/.tmux/kube-tmux/kube.tmux \
#  https://raw.githubusercontent.com/jonmosco/kube-tmux/master/kube.tmux
#chmod +x $HOME/.tmux/kube-tmux/kube.tmux
cat >>~/.tmux.conf <<EOF
set -g status-right "#(/bin/bash $HOME/.tmux/kube-tmux/kube.tmux 250 red cyan)"
EOF
tmux source ~/.tmux.conf
```


Mac Apps

- https://rectangleapp.com
- https://daisydiskapp.com
- https://bjango.com/mac/istatmenus/
- https://github.com/chipmk/docker-mac-net-connect
  - forward all ports from your docker for mac vm :)
- Wireguard
- XCode
  
On a fresh mac - make backup with timemachine first!

```shell
xcode-select --install
# find dialog and install the developer tools
mkdir -p ~/develop && cd ~develop
git clone --depth 1 https://github.com/rossbachp/brewup
cd brewup
# install brew 
./happiness -b
```

Full installation

```bash
curl -fsSL -o happiness https://raw.githubusercontent.com/rossbachp/brewup/main/happiness | bash
````

Features:

- check_macos_updated
- install_brew
- install_brewup
- install_terminal_profiles
- install_brew_packages

- https://krew.sigs.k8s.io/docs/user-guide/setup/install/
- https://github.com/Fred78290/vagrant-multipass
- https://ohmyz.sh/#install

More options:

```shell
./happiness --help
```

## Other options

- docker registry and local git server
- install MAS apps
- Install krew plugins

### Planned

- docker tap support for better access LB and docker network

```shell
# Install via Homebrew
brew install chipmk/tap/docker-mac-net-connect
# Run the service and register it to launch at boot
sudo brew services start chipmk/tap/docker-mac-net-connect
```

- Create kubernetes Resource graphs with [kubectl-graph](https://github.com/steveteuber/kubectl-graph)

```shell

docker run -d -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/secret neo4j
# argodb?
kubectl graph pods --field-selector status.phase=Running -n kube-system | dot -T svg -o pods.svg
```

- Start kubernetes cluster with k3d or kind
  - add fluxcd support :)
  - cloudflared tunnel

- support 1password vault
  - https://external-secrets.io/v0.5.7/provider-1password-automation/#deploy-a-connect-server
  - https://github.com/1Password/connect/tree/a0a5f3d92e68497098d9314721335a7bb68a3b2d/examples/kubernetes

## Mas

- https://github.com/mas-cli/mas

```shell
mas search Xcode
   497799835  Xcode (15.2)
mas search wireguard 
  1451685025  WireGuard                     (1.0.16)
mas search Whatsapp 
  310633997  WhatsApp Messenger                                       (24.4.4)
mas search BlackMagic
   425264550  Blackmagic Disk Speed Test     (3.4.2)
```

## Licensing

Copyright (c) 2024 Peter Rossbach <peter.rossbach@bee42.com>

MIT License, see [LICENSE.txt](LICENSE.txt) for more details.

Regards,

[`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
