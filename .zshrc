export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$PATH:~/.docker/bin/"
export PATH="/opt/homebrew/opt/inetutils/libexec/gnubin:$PATH"

export ZSH="$HOME/.oh-my-zsh"

export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

jdk() {
   version=$1
   export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
   java -version
}

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"
plugins=(git kubectl docker docker-compose helm mvn kube-ps1)
source $ZSH/oh-my-zsh.sh

source <(kubectl completion zsh)
source <(kind completion zsh)
source <(k3d completion zsh)
source <(helm completion zsh)
source <(flux completion zsh)