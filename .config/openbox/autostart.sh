# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

# log to the file in /tmp
exec >>/tmp/openbox-${USER}${DISPLAY}-autostart.log 2>&1

# if launched with not bash shell then exec to bash
if [ -z "$BASH_VERSION" ]; then
	echo "exec to /bin/bash"
	exec /bin/bash $HOME/.config/openbox/autostart.sh
fi


# read .bashrc
[ -f ~/.bashrc ] && PS1="" . ~/.bashrc

# applay .Xdefaults
[ -f ~/.Xdefaults ] && xrdb -merge ~/.Xdefaults

# keyboard map setting (programmer's Polish)
# - period on the numeric keypad
# - enable mouse emulation with the numeric keypad (activated by Shift+NumLock)
setxkbmap -option "kpdl:dot" -option "keypad:pointerkeys" pl

# disabling timeout for pointerkeys
xkbset exp =mousekeys

# enable numlock
python3 -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); X11.XOpenDisplay.restype = c_void_p; display = X11.XOpenDisplay(None); X11.XkbLockModifiers(c_void_p(display), c_uint(0x0100), c_uint(16), c_uint(16)); X11.XCloseDisplay(c_void_p(display))';

# unlimited access to X server from localhost (for schroot / sudo / ...)
xhost +localhost

# dameon notifications... otherwise programs may hang when trying to send them via dbus...
systemctl --user restart xfce4-notifyd


# function for window search
# $1 - regexp for WM_CLASS, $2 - regexp for whole line
win_find() {
	wmctrl -lxp | awk '$4 ~ "'"$1"'" && $0 ~ "'"$2"'" {print $1}';
}

# functions for closing (hiding in the tray), minimizing, and maximizing windows
win_close() {
	[ "$1" != "" ] && wmctrl -ic $1
}
win_hide() {
	[ "$1" != "" ] && wmctrl -b add,hidden -ir $1
}
win_maximize() {
	[ "$1" != "" ] && wmctrl -b add,maximized_vert,maximized_horz -ir $1
}

# function waits for a window to appear and returns its ID.
# $1 - step time [s], $2 - number of steps
# $3 - regexp for WM_CLASS, $4 - regexp for the entire line
win_wait() {
	count=0; win=""
	while [ "$win" = "" -a $count -lt $2 ]; do
		count=$(( $count + 1 ))
		win=`win_find "$3" "$4"`
		sleep $1
	done
	echo $win
}

# functions that wait for the specified window, and then
# close it (hide it in the tray) and minimize it
# arguments as for win_wait
win_wait_and_close() {
	win=`win_wait $@`
	if [ "$win" != "" ]; then
		wmctrl -ic $win
	fi
}
win_wait_and_hide() {
	win=`win_wait $@`
	if [ "$win" != "" ]; then
		wmctrl -b add,hidden -ir $win
	fi
}


# enable local configuration
# variables from this file are used below:
#   WALLPAPER_PATH    - if not empty, uses the wallpaper file path
#   DONT_RUN_XCOMPMGR - if set to true, does not start xcompmgr
#   DONT_RUN_DEFAPPS  - if set to true, does not start applications specified by DEFAPPS (default: claws-mail, psi-plus, and linphone)
#   DEFAPPS           - allows to change the list of default applications (when DONT_RUN_DEFAPPS != true)
if [ -f "$HOME/.config/openbox/autostart-local.sh" ]; then
        . "$HOME/.config/openbox/autostart-local.sh"
fi

if which xcompmgr && [ "$DONT_RUN_XCOMPMGR" != "true" ] ; then
	xcompmgr -c &
fi

# set wallpaper
[ "$WALLPAPER_PATH" != "" ] && feh --bg-fill $WALLPAPER_PATH &

# start panel
LANG=C.UTF8 LC_TIME=en_DK.UTF-8 TZ=Europe/Warsaw lxpanel &

# start system monitor widget
( sleep 1; conky -c ~/.config/conky/bottom_panel.conf ) &

# start clipboard manager
(
	export -n XDG_RUNTIME_DIR
	export -n QT_QPA_PLATFORMTHEME
	export DBUS_SESSION_BUS_ADDRESS=disabled:
	exec copyq
) &

# start default systray applications and hide their windows
if [ "$DONT_RUN_DEFAPPS" != "true" ] ; then
	for a in ${DEFAPPS:-thunderbird}; do
		case $a in
			thunderbird)
				DBUS_SESSION_BUS_ADDRESS=disabled: birdtray &
				;;
			claws-mail)
				$a &
				# maximize and hide Claws-mail
				( win=`win_wait 0.2 44 'claws-mail.Claws-mail' 'Claws Mail'`; win_maximize $win; win_close $win; ) &
				;;
			psi-plus)
				$a &
				# minimize Psi conference rooms and chats window
				( win_hide `win_wait 0.2 44 'tabs[.]psi'`; ) &
				;;
			linphone)
				$a &
				# hide Linphone window in the system tray on startup
				# (it doesn't have this option, but sending it close will suffice)
				( win_close `win_wait 0.2 44 'linphone[.]Linphone' 'Linphone$'`; ) &
				;;
			*)
				$a &
				;;
		esac
	done
fi

# kill empty black window (Debian Trixie)
( xdotool windowkill `win_wait 0.2 44 "N/A" "N/A"`; ) &
