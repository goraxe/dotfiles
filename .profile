# set PATH so it includes user's private bin if it exists

# reset path each time this gets sourced
if [[ -r /etc/environment ]]; then
    source /etc/environment
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

if [[ -d $HOME/node/bin || -L $HOME/node/bin ]] ; then
    PATH="${PATH}:${HOME}/node/bin"
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

