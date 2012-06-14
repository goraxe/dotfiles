#!/bin/bash

echo "xsession is started" >> /home/gordon/log/xsession

export >> /home/gordon/log/xsession

 source .xsession.local

xscreensaver &
awesome
#exec ck-launch-session gnome-session
