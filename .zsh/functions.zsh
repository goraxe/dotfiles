
creds() {
    local TYPE=$1
    local CREDS=$2

    if [[ -e $HOME/creds/$TYPE/$CREDS.sh ]]; then
        echo "loading creds ${TYPE}-$CREDS"
        export CREDS_${TYPE}=$CREDS
        source $HOME/creds/$TYPE/$CREDS.sh
    else 
        echo "creds ${TYPE}-$CREDS not found"
    fi
}
