# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

#
# general environment settings
#

[ -f ~/.profile ] && . ~/.profile


#
# if not interactive, we do not process the rest of the file
#

if [ -z "$PS1" ]; then
	return
fi


#
# invoking tmux when bash is launched from a terminal emulator or terminal
#

if [ "$TERM" = "xterm" ]; then
	export TERM=xterm-256color
fi

exec_tmux_choose_session() {
	if ! (which whiptail >& /dev/null && which tmux >& /dev/null); then
		return
	fi

	TMP_FILE=`mktemp /tmp/tmux_choose_session.XXXXX`

	sesions=$(tmux list-sessions 2> /dev/null | tr -d '"'"'" | sed -E -e 's#^([^:]+): (.*)#"\1" "\2"#')
	dialog_opt1='--menu "tmux is running - choose tmux session:" 0 0 0 _NEW_SES_ "start new tmux sesion" _NO_TMUX_ "start shell instand tmux"'
	dialog_opt2=''
	eval whiptail $dialog_opt1 $sesions $dialog_opt2 2> "$TMP_FILE"
	if [ $? -ne 0 ]; then
		exit
	fi

	session=`cat "$TMP_FILE"`
	rm -f "$TMP_FILE"
	case $session in
		_NEW_SES_)
			eval exec tmux new-session $(env | sed -E -e 's#"#\\"#g' -e 's#^([^=]+)=(.*)# -e "\1"="\2"#')
			# NOTE: sed preprocessing + eval for support variables with spaces, quotes, etc like
			#       export XXX0="a b c" XXX1="a='a bc'" XXX2="a=\'abc\'" XXX3="a=\"b" XXX4="a;b\;c"
			;;
		_NO_TMUX_)
			unset sesions TMP_FILE dialog_opt1 dialog_opt2
			clear
			;;
		*)
			exec tmux attach-session -t $session
			;;
	esac
}

if [[ $- != *c* ]]; then
	parent=`tr '\0' '\n' < /proc/$PPID/cmdline | head -n1`
	if echo $parent | egrep '^((/usr)?/bin/)?(xterm|konsole|xfce4-terminal|login)' > /dev/null; then
		exec_tmux_choose_session
	fi
fi


#
# bash configuration
#

# prompt etc. depending on the terminal
case $TERM in
	# colored prompt and window title in xterms and screen / tmux
	xterm*|screen*)
		PS1='\[\033[01;31m\]\u@\H${debian_chroot:+\[\033[01;33m\]>$debian_chroot}\[\033[0m\]:\[\033[01;36m\]\w\[\033[0m\]\$ '
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}${debian_chroot:+ ($debian_chroot)}:${PWD/${HOME}/~}\007"'
		;;
	# regular prompt on other terminals
	*)
		PS1='\u@\H${debian_chroot:+ ($debian_chroot)}:\w\$ '
		;;
esac

# ignoring repetitions and selected commands in history
HISTIGNORE="&:ls:[bf]g:cd:exit:kill *:history*"

# ignoring duplicates, clearing repetitions, and ignoring commands starting with a space
HISTCONTROL=ignoredups:erasedups:ignorespace

# number of commands in the history file
HISTSIZE=5000

# appending to the history file after each command
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# adding to the history file along with cleaning up duplicates when exiting the shell
_history_clean() {
	if mkdir /dev/shm/bash_${USER}_history.lock; then
		
		NEWHISTORY=`mktemp /dev/shm/history.tmp.XXXXXXXXX`;
		tac $HISTFILE | awk '! x[$0]++ {print $0}' | tac > $NEWHISTORY
		\mv $NEWHISTORY $HISTFILE;
		
		rmdir /dev/shm/bash_${USER}_history.lock;
	fi
}
trap _history_clean EXIT

# history file backup
\cp $HISTFILE ~/.bash_history.bck.`date +%u`

# advanced autocomplete
[ -f /etc/bash_completion ] && . /etc/bash_completion

# checking the window size after each command
shopt -s checkwinsize

# command for disable history saving
alias 'history_stop'='HISTFILE=/dev/null'
