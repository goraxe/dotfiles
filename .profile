# set PATH so it includes user's private bin if it exists

# reset path each time this gets sourced
if [[ -r /etc/environment ]]; then
    source /etc/environment
fi

if [[ -r ${HOME}/.bash.p4 ]]; then
    source ${HOME}/.bash.p4
fi

if [[ -r ${HOME}/.profile.local ]]; then 
    source ${HOME}/.profile.local
fi

if [[ $(uname -s) -eq "Darwin" ]]; then
    PATH="/usr/local/bin:$PATH"
fi

if [[ -d ${HOME}/bin || -L ${HOME}/bin ]] ; then
    PATH="${HOME}/bin:${PATH}"
fi

if [[ -d ${HOME}/bin.local || -L ${HOME}/bin.local ]] ; then
    PATH="${HOME}/bin.local:${PATH}"
fi

if [[ -d ${HOME}/.local/bin|| -L ${HOME}/.local/bin ]] ; then
    PATH="${HOME}/.local/bin:${PATH}"
fi

if [[ -d $HOME/go/bin || -L $HOME/go/bin ]] ; then
    PATH="${PATH}:${HOME}/go/bin"
fi

if [[ -d $HOME/projects/go ]]; then
    GOPATH="$HOME/projects/go"
    export GOPATH
fi

if [[ -d $HOME/projects/go/bin || -L $HOME/projects/go/bin ]] ; then
    PATH="${PATH}:${HOME}/projects/go/bin"
fi

if [[ -d $HOME/.local/lib/aws/bin || -L $HOME/.local/lib/aws/bin ]] ; then
    PATH="${PATH}:${HOME}/.local/lib/aws/bin"
fi

if [[ -d $HOME/perl5/bin || -L $HOME/perl5/bin ]] ; then
    PATH="${PATH}:${HOME}/perl5/bin"
fi

if [[ -d $HOME/node/bin || -L $HOME/node/bin ]] ; then
    PATH="${PATH}:${HOME}/node/bin"
fi

if [[ -d $HOME/.yarn/bin || -L $HOME/.yarn/bin ]] ; then
    PATH="${PATH}:${HOME}/.yarn/bin"
fi

if [[ -d $HOME/.gem/ruby/2.5.0/bin ]]; then
    PATH=${PATH}:$HOME/.gem/ruby/2.5.0/bin
fi

if [[ -d $HOME/neo4j/bin || -L $HOME/neo4j/bin ]] ; then
    PATH="${PATH}:${HOME}/neo4j/bin"
fi

ANDROID_HOME="$HOME/android-sdks"

if [[ -e "${ANDROID_HOME}/tools" ]]; then
    PATH="$PATH:${ANDROID_HOME}/tools"
fi

if [[ -e "${ANDROID_HOME}/platform-tools" ]]; then
    PATH="$PATH:${ANDROID_HOME}/platform-tools"
fi

if [[ -e "$HOME/apache-maven/bin" ]]; then
    PATH="$HOME/apache-maven/bin:$PATH"
fi

if [[ -e "$HOME/.chefdk/gem/ruby/2.1.0/bin" ]]; then
    PATH="$PATH:$HOME/.chefdk/gem/ruby/2.1.0/bin"
fi

if [[ -e "$HOME/usr/lib/pkg-config" ]]; then
    PKG_CONFIG_PATH="$HOME/usr/lib/pkg-config" 
fi

if [[ -e "$HOME/usr/lib" ]]; then
    LD_LIBRARY_PATH=$HOME/usr/lib
fi

if [[ -e "$HOME/.tfenv/bin" ]]; then
    PATH="$PATH:$HOME/.tfenv/bin"
fi

if command -v nvim &> /dev/null; then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

export ANDROID_HOME PATH PKG_CONFIG_PATH LD_LIBRARY_PATH

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

if [[ -e "$HOME/.krew/bin" ]]; then
    export PATH="$PATH:$HOME/.krew/bin"
fi

# make ls colors a little less garish
export LS_COLORS="ow=41,37"

# added by travis gem
[ -f /home/goraxe/.travis/travis.sh ] && source /home/goraxe/.travis/travis.sh

[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
