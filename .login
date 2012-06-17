# vim: ft=sh
SSH_AGENT_PID=""

source $HOME/.dotfiles

function do_ssh_add {
    if [[ -e "$HOME/.ssh/id_rsa" ]]; then 
        redo=1
        while [[ $redo != 0 ]]
        do
                ssh-add
                if [[ $? == 0 ]]; then
                    redo=0
                else
                    echo "FAIL: Try again"
                fi
        done
    else
        echo "failed to find id_rsa?!?!?"
    fi
}

# if we already set things up lets do it again
[ ! -z "$LOGGED_IN" ] && return

function have_agent_connection {
    local __resultvar=$1
    local res=
    if [[ ( ! -z $SSH_AUTH_SOCK ) && -e $SSH_AUTH_SOCK && -S $SSH_AUTH_SOCK ]]; then
        res="1"
    fi
    if [[ ! -z "$__resultvar" ]]; then
        eval $__resultvar="'$res'"
    else
        echo "$res"
    fi
}

# check if we have a running AUTH SOCK
if [ $(have_agent_connection) ]; then
    # tunneld AUTH and we have an identitiy file so add it  
    echo "tunneled auth"
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > ~/.ssh_agent.sh
    if [[ -e ${HOME}/.ssh/id_rsa ]]; then
        do_ssh_add
    fi
# check if a previous session has started an agent
elif [[ -e ~/.ssh_agent.sh ]]; then
    . ~/.ssh_agent.sh
    if [ $(have_agent_connection) ]; then
        echo "connecting to current agent"
    else
        echo "starting new agent"
        ssh-agent -s > ~/.ssh_agent.sh
        . ~/.ssh_agent.sh
    fi
    do_ssh_add
else
    echo "starting new agent"
    ssh-agent -s > ~/.ssh_agent.sh
    . ~/.ssh_agent.sh
    do_ssh_add
fi

# make sure we have an agent before syncing
if [[ -e ~/bin/sync_links.sh ]]; then
    echo "sync"
    ~/bin/sync_links.sh
fi

# overwrite the trap handlers to defaults at this point
trap - INT TERM EXIT

if which tmux ; then
    if [[ "x$POWERDETACH" == "xyes" ]]; then
        echo "pow detach tmux"
        tmux detach -P
    elif [[ "x$DETACH" == "xyes" ]]; then
        echo "detach tmux"
        tmux detach
    fi
    echo "attach tmux"
    tmux attach
elif which screen ; then
    if [[ "x$POWERDETACH" == "xyes" ]]; then
        screen -R -D
        echo "pow detach screen"
    elif [[ "x$DETACH" == "xyes" ]]; then
        screen -R -dd
        echo "detach screen"
    else
        echo "attach screen"
        screen -xRR
    fi
fi
