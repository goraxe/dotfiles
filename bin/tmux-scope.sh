#!/bin/bash
SESSION_NAME="$1"
PANE_PID="$2"

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
export XDG_RUNTIME_DIR="/run/user/1000"

exec &>>/tmp/tmux-scope.log

# Create a transient scope and move the pane's process into it
busctl call --user \
	org.freedesktop.systemd1 \
	/org/freedesktop/systemd1 \
	org.freedesktop.systemd1.Manager \
	StartTransientUnit 'ssa(sv)a(sa(sv))' \
	"tmux-${SESSION_NAME}.scope" "fail" \
	2 \
	"Slice" s "tmux.slice" \
	"PIDs" au 1 "${PANE_PID}" \
	0

true
