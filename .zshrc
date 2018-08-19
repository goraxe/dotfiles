# The following lines were added by compinstall

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

source ~/.zplug/init.zsh



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

zplug "~/.zsh", from:local

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/gradle",   from:oh-my-zsh
zplug "plugins/zsh_reload",   from:oh-my-zsh
zplug "plugins/per-directory-history", from:oh-my-zsh

zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "b4b4r07/emoji-cli", \
    on:"stedolan/jq"

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
