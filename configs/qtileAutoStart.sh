#!/bin/bash

function run {
	if ! pgrep -x $(basename $1 | head -c 15) 1>/dev/null;
	then
		$@&
	fi
}

#starting utility applicaions at boot time
sxhkd -c ~/mArch/configs/sxhkdrc &
#run nitrogen --restore &
#run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
