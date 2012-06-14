# set PATH so it includes user's private bin if it exists
if [[ -d ${HOME}/bin || -L ${HOME}/bin ]] ; then
    PATH="${HOME}/bin:${PATH}"
fi

if [[ -d ${HOME}/bin.local || -L ${HOME}/bin.local ]] ; then
    PATH="${HOME}/bin.local:${PATH}"
fi

if [[ -d $HOME/go/bin || -L $HOME/go/bin ]] ; then
    PATH="${HOME}/go/bin:${PATH}"
fi

if [[ -d $HOME/node/bin || -L $HOME/node/bin ]] ; then
    PATH="${HOME}/node/bin:${PATH}"
fi

export PATH

