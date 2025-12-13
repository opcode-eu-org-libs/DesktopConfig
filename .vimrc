" SPDX-FileCopyrightText: Robert Ryszard Paciorek <rrp@opcode.eu.org>
" SPDX-License-Identifier: MIT

" use plugins from ~/.vim/plugins/ ...
source ~/.vim/plugins/*

if $TERM == "xterm-256color" || $TERM == "screen-256color"
  set t_Co=256
endif

" use xtertm settings for screen and tmux
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $TERM == "screen"
  set term=xterm
endif

" window title (used by term emulators and multiplexers)
set title titlestring=%t%(\ %M%)%(\ (%{expand(\"%:~:.:h\")})%)%(\ %a%)

" use vim, not vi by default
set nocompatible

" command line history size
set history=50

" we usually use a dark background
set background=dark

" syntax highlighting, automatic formatting
syntax on

" automatic indentation continuation
set autoindent

" making indentations related to curly brace, etc.
set smartindent

" automatic continuation of comments
set formatoptions+=r
set formatoptions+=o

" automatic continuation of numbered lists
set formatoptions+=n

" switching paste mode via F2 (disables autoformatting... convenient when pasting via terminal)
set pastetoggle=<F2>

" code folding settings (zc zo zR ... see :help folding)
set foldmethod=indent " zawijanie oparte na wcieciach
set nofoldenable      " zawijanie sterowane tylko manualnie
set foldnestmax=10
set foldlevel=1


" correct arrows etc. in Solaris
if &term != 'xterm' 
	set term=linux 

	func Backspace()
	if col('.') == 1
		if line('.')  != 1
		return  "\<ESC>kJ\<Del>i"
		else
		return ""
		endif
	else
		return "\<Left>\<Del>"
	endif
	endfunc

	inoremap <BS> <c-r>=Backspace()<CR>

	" :map OD <Right>
	" :map OC <Left>
	" :map OB <Down>
	" :map OA <Up>
endif

" navigating along broken lines as normal
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" showing line breaks with an indented +
"set showbreak=\ +\ 

" showing line numbers
set number

" larger buffer - works better ..
" set wh=250

" Sets command-line completion. This ensures that <Tab> will always display a list of possibilities rather than one value at a time.
set wildmode=longest,list
set wildmenu

" Mouse support enabled... to use the mouse with xterm (e.g. copying to the x clipboard) you need to use it with shift
set mouse=a

" Synchronizing the default register (yy, dd, ..., middle mouse button operations) with the X clipboard (selection).
" This requires Vim compiled with xterm_clipboard (e.g., the vim-gtk package).
set go=
set clipboard=unnamed

" Automatically places the cursor where it was last in the file
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Status line should be always visible
set laststatus=2
