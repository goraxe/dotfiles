#!/bin/bash

echo "xsession is started" >> ~/log/xsession

export >> ~/log/xsession

if [[ -e .xsession.local ]]; then
 source .xsession.local
fi

xscreensaver &
awesome
#exec ck-launch-session gnome-session
