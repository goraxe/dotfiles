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
ssh ${SSH_OPTS} $INSTALL_HOST "cat > .dotfiles" <<EOT
VCS_UPDATE_CMD="git pull"
VCS_COMMIT_CMD="git commit -a"
VCS_CREATE_CMD="git clone"


VCS_LOCATION="${USER}@${HOSTNAME}:dotfiles"
VCS_LOCATION_HOME="${USER}@${HOSTNAME}:dotfiles"

CHECKOUT_HOME="${HOME}/dotfiles"

VCS_DIRS="HOME"
EOT

ssh $INSTALL_HOST ${SSH_OPTS} mkdir .ssh
ssh $INSTALL_HOST ${SSH_OPTS} mv .ssh/config .ssh/config.orig

ssh $INSTALL_HOST ${SSH_OPTS} "cat > .ssh/config" <<EOT
StrictHostKeyChecking = no
EOT


#cat ~/tmp/dotfile | ssh ${SSH_OPTS} $INSTALL_HOST "cat > .dotfiles"
cat ~/bin/sync_links.sh | ssh ${SSH_OPTS} $INSTALL_HOST "cat > bin/sync_links.sh"
ssh ${SSH_OPTS} $INSTALL_HOST chmod a+x bin/sync_links.sh
echo "making log dir"
ssh ${SSH_OPTS} $INSTALL_HOST mkdir ~/log
echo "running sync"
ssh ${SSH_OPTS} $INSTALL_HOST "bin/sync_links.sh | tee ~/log/install-$INSTALL_HOST.log"
pushd ~/dotfiles
git remote add -m ${INSTALL_HOST} -f ${INSTALL_HOST} ${INSTALL_HOST}:dotfiles

popd
