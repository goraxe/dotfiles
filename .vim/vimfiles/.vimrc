
set nocompatible
set bs=2
set columns=80
set background=dark
set wrapmargin=8
syntax on
set ruler
set list
set listchars=tab:>-,trail:-,eol:@
set autowrite
set autochdir
set number
colorscheme desert
highlight Folded guibg=grey50 guifg=blue
highlight FoldColumn guibg=grey30 guifg=darkblue
set foldcolumn=2
set foldmethod=syntax
syn region myFold start="{" end="}" transparent fold
