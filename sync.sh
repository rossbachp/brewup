#!/bin/bash
cd "$(dirname "$0")" || exit 5
git pull

function doIt() {
  if [ ! -d ~/develop ]; then
    mkdir ~/develop
  fi
  if [ ! -d ~/develop/z ]; then
    git clone https://github.com/rupa/z.git ~/develop/z
  fi
  if [ ! -d ~/.logs ]; then
    mkdir ~/.logs
    chmod 700 ~/.logs
  fi
  if [ ! -d ~/.vim/bundle/vundle ]; then
    git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
  fi

  rsync -av Library ~
  
  rsync --exclude ".git/" --exclude "images/" --exclude Library --exclude "add-on/" \
        --exclude "sync.sh" --exclude "README.md" \
        --exclude "brew-tap.txt" \
        --exclude "brew.txt" \
        --exclude "krew.txt" \
        --exclude "mas.txt" \
        --exclude "cask-minimal.txt" --exclude "cask-full.txt" \
        --exclude "happiness" --exclude "plist" \
        --exclude "fetch-code-prefs.sh" \
        --exclude "npm-install.sh" --exclude "LICENSE.txt" \
        --exclude ".gitkeep" --exclude ".gitconfig" --exclude "fetch-sublime-prefs.sh" \
        -av . ~
  if [ ! -f ~/.gitconfig ]; then
    cp .gitconfig ~/.gitconfig
  fi

  if which vim >/dev/null 2>&1; then
    vim +BundleInstall +qall
  fi

  # Visual Studio Code
  if [ -f ./Library/Application\ Support/Code/User/extensions.txt ]; then
    extensions=$(cat ./Library/Application\ Support/Code/User/extensions.txt)
    if which code >/dev/null 2>&1; then
      for ext in $extensions; do
        code --install-extension "$ext"
      done
    fi
  fi
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt
  fi
fi

unset doIt
source ~/.bash_profile
