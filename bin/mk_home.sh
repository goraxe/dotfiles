#!/bin/bash


INSTALL_HOST=$1

function usage {
echo <<EOT
    $0: user@target host
will setup the user to have the dotfiles folder deployed to them and cause an initial sync
EOT
}

if [[ "${INSTALL_HOST}x" == "x" ]]; then
    usage
    exit
fi


SSH_OPTS="-o StrictHostKeyChecking=no -A -Y "
SSH_OPTS="${SSH_OPTS} ${*:2}"
SOURCE_HOST=$(hostname -f)
echo "INSTALL_HOST ${INSTALL_HOST}"
echo "SOURCE_HOST ${SOURCE_HOST}"
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


VCS_LOCATION="${USER}@${SOURCE_HOST}:dotfiles"
VCS_LOCATION_HOME="${USER}@${SOURCE_HOST}:dotfiles"

CHECKOUT_HOME="\${HOME}/dotfiles"
DEST_HOME="\${HOME}"

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

ssh $INSTALL_HOST ${SSH_OPTS} mv .ssh/config.orig .ssh/config


popd
