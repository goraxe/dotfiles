# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/games"

export TMP=$HOME/tmp

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export EDITOR=vim
export HOSTNAME=`hostname -s`
# make less more friendly for non-text input files, see lesspipe(1)
if [ ! -e /etc/gentoo-release ]; then 
    [ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"
fi

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
#case "$TERM" in
#xterm-color)
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#    ;;
#*)
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#    ;;
#esac

# Comment in the above and uncomment this below for a color prompt
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
screen)
	echo -n -e "\033k${HOSTNAME}\033\\"
	PROMPT_COMMAND='echo -n -e "\033k${HOSTNAME}\033\\"; if [[ -e ~/.ssh_agent.sh ]]; then . ~/.ssh_agent.sh; fi; if [[ -e ~/.env_load ]]; then . ~/.env_load; fi'
	;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

if [ -f ~/.bashrc.local ]; then
    . ~/.bashrc.local
fi

if [[ -e  $HOME/.profile ]]; then
    source $HOME/.profile
fi

eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)


# >>>> Vagrant command completion (start)
. /opt/vagrant/embedded/gems/2.2.16/gems/vagrant-2.2.16/contrib/bash/completion.sh
# <<<<  Vagrant command completion (end)
. "$HOME/.cargo/env"
