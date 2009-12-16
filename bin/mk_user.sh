#!/bin/bash

INSTALL_HOST=$1
INSTALL_USER=$2
SSH_OPTS=${*:3}
SSH_KEY=`ssh-add -L`

echo "INSTALL_HOST ${INSTALL_HOST}"
echo "INSTALL_USER ${INSTALL_USER}"
echo "SSH_OPTS ${SSH_OPTS}"
echo "SSH_KEY ${SSH_KEY}"

ssh -t root@${INSTALL_HOST}  "

echo ""SSH_TTY ${SSH_TTY}""
echo ""creating user ${INSTALL_USER}""
if [[ -e /etc/redhat-release ]]; then
	useradd ${INSTALL_USER} -G wheel -m -s /bin/bash
else
	 useradd ${INSTALL_USER} -G sudo,adm -m -s /bin/bash 
fi
mkdir -p /home/${INSTALL_USER}/.ssh
echo ${SSH_KEY} >> /home/${INSTALL_USER}/.ssh/authorized_keys
passwd ${INSTALL_USER} 
"
