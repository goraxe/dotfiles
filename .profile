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

if [[ -d ${HOME}/bin || -L ${HOME}/bin ]] ; then
    PATH="${PATH}:${HOME}/bin"
fi

if [[ -d ${HOME}/bin.local || -L ${HOME}/bin.local ]] ; then
    PATH="${PATH}:${HOME}/bin.local"
fi

if [[ -d $HOME/go/bin || -L $HOME/go/bin ]] ; then
    PATH="${PATH}:${HOME}/go/bin"
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

if [[ -d $HOME/.gem/ruby/1.9.1/bin ]]; then
    PATH=${PATH}:$HOME/.gem/ruby/1.9.1/bin 
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

export ANDROID_HOME PATH

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/home/gordon/.gvm/bin/gvm-init.sh" ]] && source "/home/gordon/.gvm/bin/gvm-init.sh"
