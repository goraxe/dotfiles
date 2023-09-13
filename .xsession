#!/bin/bash

echo "xsession is started" >> ~/log/xsession


if [[ -e .xsession.local ]]; then
 . .xsession.local
fi

. ~/.profile

export >> ~/log/xsession

picom --config ~/.picom.conf &
# xscreensaver &
# awesome
#exec ck-launch-session gnome-session
