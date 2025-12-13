# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

#
# basic settings
#

# default file permissions
umask 0022


# locale and timezone configuration
{
	export LANG="pl_PL.UTF-8"     # general setting - Polish
	export LC_MESSAGES="C.UTF-8"  # untranslated program messages (`ps --pomoc all` is too much)
	export LC_TIME="en_DK.UTF-8"  # date display format compliant with ISO 8601 (e.g. for `date +%c`)
	export LC_COLLATE="pl_PL.UTF-8"   # custom sorting style - see /usr/share/i18n/locales/pl_PL.diff
	export LC_NUMERIC="C.UTF-8"   # C-style decimal separator (dot)
	export TZ=UTC                 # UTC time zone (you can also specify, e.g., Europe/Warsaw)
} 2> /dev/null

# checking the availability of the set locales and possibly returning to C.UTF-8
perl -e exit 2>&1 | grep 'Setting locale failed' > /dev/null 2>&1 && export LC_ALL=C.UTF-8;


# paths
[ -d $HOME/.tex ] && export TEXINPUTS=".:$HOME/.tex:"
[ -d $HOME/.bin ] && export PATH=$HOME/.local/bin:$HOME/.bin:"${PATH}"


#
# configuration of additional programs via environment variables
#

#  - pip packages installed globally (without venv)
export PIP_BREAK_SYSTEM_PACKAGES=1

# (see also ~/.xsessionrc for variables for graphics mode)



#
# if not interactive, we do not process the rest of the file
#

if [ -z "$PS1" ]; then
	return
fi


#
# environment variables and aliases (for bash and zsh interactive sessions)
#

# editor
if [ -x `which vim` ]; then
	alias vi="vim"
	export EDITOR=vim
else
	export EDITOR=vi
fi


# colors
if [ "$TERM" != "dumb" ]; then
	eval `dircolors -b`
	alias ls="ls --color=auto --time-style=+\" %Y-%m-%d %H:%M:%S \" -h"
	alias grep='grep --color'
	alias egrep='egrep --color'
fi


# search and replace
rgrep() { grep -R "$@" .; }
regrep() { egrep -R "$@" .; }
ggrep() { (git ls-tree -r HEAD --name-only; git ls-files --others --exclude-standard) | while read f; do [ -f "$f" ] &&  grep -H "$@" "$f"; done }
rreplace() {
	if [ $# -lt 2 ]; then
		echo USAGE: $0 str1 str2 [sep]
		return
	fi
	sep=${3:-^}
	\grep -Rl "$1" . | while read f; do
		[ -L "$f" ] || sed -e "s${sep}${1}${sep}${2}${sep}g" -i "$f";
	done;
}
replace() {
	if [ $# -lt 3 ]; then
		echo USAGE: $1 str1 str2 sep [file ...]
		return
	fi
	a=$1
	b=$2
	c=$3
	shift 3
	\grep -l "$a" "$@" | while read f; do
		[ -L "$f" ] || sed -e "s${s}$a${s}$b${s}g" -i "$f";
	done;
}

# pausing the process
pause() { kill -STOP $1; read x; kill -CONT $1; };

# diff for binary files
hdiff() { f1=$1; f2=$2; shift 2; diff $@ <(xxd "$f1") <(xxd "$f2"); }

# cp, mv, rm asks about deleting/overwriting files
alias 'cp'="cp -i"
alias 'mv'="mv -i"
alias 'rm'="rm -i"

# bc uses floating point number by default
alias 'bc'='bc -l'

# less without clearing the screen, with automatic exit when less than screen and coloring passthrough
alias less='less -XFR'

# preformatted time and date information
alias 'date_iso'='date +"%A,  %Y-%m-%d %H:%M:%S %z (%Z)%n time stamp: %s"'
alias 'date_iso_utc'='date_iso --utc'

# converting PDFs to grayscale
pdf2gray() { gs -sOutputFile="$2"  -sDEVICE=pdfwrite  -sColorConversionStrategy=Gray  -dProcessColorModel=/DeviceGray  -dCompatibilityLevel=1.4 -dNOPAUSE  -dBATCH "$1"; }

# others
alias sigrok=pulseview
alias y="yt-dlp --prefer-free-formats -f 'bv*+ba[format_note*=original]/bv*+ba/b'"
alias yy="y -f 'bv[height<=1080]+ba[format_note*=original]/bv[height<=1080]+ba/b[height<=1080]'"
alias yys1='yy --write-auto-subs --write-subs --sub-langs "pl-orig,pl,en-orig,en"'
alias yys2='yy --write-auto-subs --write-subs --sub-langs "pl-orig,en-orig,en"'


#
# settings for pass command (http://www.passwordstore.org/)
#

. ~/.password-store/.profile.inc.sh

#
# local settings
#

if [ -f "$HOME/.profile.local" ]; then
	. "$HOME/.profile.local"
fi
