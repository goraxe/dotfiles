# The following lines were added by compinstall

if [[ -e /usr/local/share/zsh/functions ]]; then
    export FPATH=$FPATH:/usr/local/share/zsh/functions
fi

zstyle ':completion:*' completer _list _oldlist _expand _complete _ignored _correct _approximate
zstyle ':completion:*' file-sort name
zstyle ':completion:*' format '---> %d:'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' max-errors 3 numeric
zstyle ':completion:*' menu select=5
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'errors :%e>'
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' squeeze-slashes true
zstyle :compinstall filename '/home/goraxe/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd notify
bindkey -v
# End of lines configured by zsh-newuser-install
DISABLE_AUTO_TITLE=true

if [[ -e /usr/local/opt/zplug ]]; then
    export ZPLUG_HOME=/usr/local/opt/zplug
    source $ZPLUG_HOME/init.zsh
elif [[ -e /usr/share/zplug ]]; then
    source /usr/share/zplug/init.zsh
else
    export ZPLUG_HOME=$HOME
    source $ZPLUG_HOME/init.zsh
fi
# source ~/.zplug/init.zsh



#for file in $HOME/.zsh/*.zsh
#do
#    source $file
#done

if [[ -e  $HOME/.aliases ]]; then
    source $HOME/.aliases
fi

if [[ -e  $HOME/.profile ]]; then
    source $HOME/.profile
fi

if [[ -e /etc/zsh_command_not_found ]]; then
   source /etc/zsh_command_not_found
fi

zplug "zplug/zplug"
zplug "~/.zsh", from:local

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/gradle",   from:oh-my-zsh
zplug "plugins/zsh_reload",   from:oh-my-zsh
zplug "plugins/per-directory-history", from:oh-my-zsh
zplug "plugins/tmux", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "plugins/dotenv", from:oh-my-zsh # interesting alternatives https://github.com/direnv/direnv & https://github.com/Tarrasch/zsh-autoenv
zplug "plugins/golang", from:oh-my-zsh
zplug "plugins/helm", from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/emoji", from:oh-my-zsh

zplug "reegnz/aws-vault-zsh-plugin"
zplug "blimmer/zsh-aws-vault"

# TODO
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-auto-fetch
# https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git-extras

zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "b4b4r07/emoji-cli", \
    on:"stedolan/jq"

zplug "plugins/ng", from:oh-my-zsh

#zplug "themes/johnathan", from:oh-my-zsh
zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme

#THIS MUST BE AT THE END OF THE FILE FOR GVM TO WORK!!!
[[ -s "/home/gordon/.gvm/bin/gvm-init.sh" ]] && source "/home/gordon/.gvm/bin/gvm-init.sh"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/goraxe/.sdkman"
[[ -e "/home/goraxe/.sdkman/bin/sdkman-init.sh" ]] && source "/home/goraxe/.sdkman/bin/sdkman-init.sh"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

SPACESHIP_TIME_SHOW=true
SPACESHIP_HOST_SHOW=true
SPACESHIP_EXIT_CODE_SHOW=true
zplug load --verbose

SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECONTEXT_COLOR_GROUPS=(
  # red if namespace is "kube-system"
  red    '\(kube-system)$'
  red   'viz-production'
  # else, 
  green 'default'
  green 'viz-x'
  green 'viz-wreckit'
  # else, yellow if the entire content is "test-" followed by digits, and no namespace is displayed
  yellow 'viz-staging'
)

PATH="/Users/gordon.irving/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/gordon.irving/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/gordon.irving/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/gordon.irving/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/gordon.irving/perl5"; export PERL_MM_OPT;



# Shows selected AWS-cli profile.
spaceship_aws() {
  SPACESHIP_AWS_PROFILE="${AWS_PROFILE:-"$AWS_VAULT"}"

  [[ $SPACESHIP_AWS_SHOW == false ]] && return

  # Check if the AWS-cli is installed
  spaceship::exists aws || return

  # Is the current profile not the default profile
  [[ -z $SPACESHIP_AWS_PROFILE ]] || [[ "$SPACESHIP_AWS_PROFILE" == "default" ]] && return

  # Show prompt section
  spaceship::section \
    "$SPACESHIP_AWS_COLOR" \
    "$SPACESHIP_AWS_PREFIX" \
    "${SPACESHIP_AWS_SYMBOL} $SPACESHIP_AWS_PROFILE [$AWS_REGION]" \
    "$SPACESHIP_AWS_SUFFIX"
}
