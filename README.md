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

## brewup your mac

With the bee42 honeypod dotfiles installer

- https://github.com/nvm-sh/nvm
- https://github.com/moovweb/gvm
- https://github.com/rupa/z.git
- https://github.com/gmarik/vundle.git

Mac Apps

- https://rectangleapp.com
- https://daisydiskapp.com
- https://bjango.com/mac/istatmenus/
- https://github.com/chipmk/docker-mac-net-connect
  - forward all ports from your docker for mac vm :)
  
```shell
curl -fsSL https://raw.githubusercontent.com/rossbachp/brewup/main/happiness | bash


# Install via Homebrew
brew install chipmk/tap/docker-mac-net-connect
# Run the service and register it to launch at boot
sudo brew services start chipmk/tap/docker-mac-net-connect
```

Features:

- check_macos_updated
- install_brew
- install_brewup
- install_terminal_profiles
- install_brew_packages

- https://krew.sigs.k8s.io/docs/user-guide/setup/install/
- https://github.com/Fred78290/vagrant-multipass
- https://ohmyz.sh/#install

## Completions

```shell
. <(flux completion zsh)
```

```shell
# https://github.com/steveteuber/kubectl-graph

docker run -d -p 7474:7474 -p 7687:7687 -e NEO4J_AUTH=neo4j/secret neo4j
# argodb?
kubectl graph pods --field-selector status.phase=Running -n kube-system | dot -T svg -o pods.svg
```

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

MIT License, see LICENSE.txt for more details.

Regards,

- [`|-o-|` The pathfinder - Peter](mailto://peter.rossbach@bee42.com)
