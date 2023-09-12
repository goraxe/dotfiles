#!/bin/bash

echo "xsession is started" >> ~/log/xsession


if [[ -e .xsession.local ]]; then
 . .xsession.local
fi

. ~/.profile

export >> ~/log/xsession

xscreensaver --no-splash &
# awesome
#exec ck-launch-session gnome-session
