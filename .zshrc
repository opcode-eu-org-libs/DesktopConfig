# SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
# SPDX-License-Identifier: MIT

[ -f ~/.profile ] && . ~/.profile

PROMPT='%B%F{red}%n@%m%f%b:%B%F{cyan}%~%f%b%(!.#.$) '
RPROMPT='%(?.%F{green}√.%F{red}?%?)%f'

# history
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# keymap
bindkey -e

# compinstall
zstyle :compinstall filename '/rrp/.zshrc'
autoload -Uz compinit
compinit
