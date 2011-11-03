# ~/.bash_logout: executed by bash(1) when login shell exits.

# when leaving the console clear the screen to increase privacy

if [ "$SHLVL" = 1 ]; then
    # kill current ssh-agent
    . ~/.ssh_agent.sh
    ssh-add -d
    rm ~/.ssh_agent.sh
    [ -x /usr/bin/clear_console ] && /usr/bin/clear_console -q
fi


#vim: ft=sh
