#!/bin/bash


INSTALL_HOST=$1
SSH_OPTS=${*:2}
echo "INSTALL_HOST ${INSTALL_HOST}"
echo "SSH_OPTS ${SSH_OPTS}"
echo "mkdir bin"
ssh-copy-id $INSTALL_HOST

ssh $INSTALL_HOST ${SSH_OPTS} mkdir bin
echo "copying sync"
# we do it this way due to inconsitent -p -P with scp ssh
cat ~/bin/sync_links.sh | ssh ${SSH_OPTS} $INSTALL_HOST "cat > bin/sync_links.sh"
ssh ${SSH_OPTS} $INSTALL_HOST chmod a+x bin/sync_links.sh
echo "making log dir"
ssh ${SSH_OPTS} $INSTALL_HOST mkdir ~/log
echo "running sync"
ssh ${SSH_OPTS} $INSTALL_HOST "bin/sync_links.sh | tee ~/log/install-$INSTALL_HOST.log"
