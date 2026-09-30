#vim: ft=sh

TRAPINT() {
    echo "No ^C here" 

#    source .login
    return 0;
}

if [[ -e .login ]]; then
    source .login
fi
