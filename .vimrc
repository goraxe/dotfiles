set nocompatible
set bs=2
set ts=4
set sw=4
set expandtab
set wrapmargin=0
syntax on
set autowrite
set modeline

"if has("netbeans_intg")
"	set autochdir
"endif

set number

" set exapndtabs
set expandtab

" display
" set columns=80

"set background=dark
"colorscheme desert

"highlight Folded guibg=grey50 guifg=blue
"highlight FoldColumn guibg=grey30 guifg=darkblue


set foldcolumn=2
set foldmethod=syntax
syn region myFold start="{" end="}" transparent fold

set ruler
set list
set listchars=tab:>-,trail:-,eol:@

set showcmd
set clipboard=unnamed

" turn on spell-checking everywhere
syn spell toplevel
set spelllang=en_gb

" Plugin options
	"GetLatest
	let g:GetLatestVimScripts_options=""
	
	" TagList
	let Tlist_Close_On_Select			= 1
    let Tlist_Auto_Open = 0
	let Tlist_Display_Prototype			= 1
	let Tlist_File_Fold_Auto_Close		= 1
	let Tlist_GainFocus_On_ToggleOpen	= 1
	let Tlist_Process_File_Allways		= 1
	" possibly just a GUI option
	let Tlist_Show_Menu 				= 1

	" perlsupport options
	let g:Perl_AuthorName = "Gordon Irving"
	let g:Perl_Author = "Gordon Irving"
	let g:Perl_Email  = "goraxe@cpan.org"

	" options for perl.vim
	let perl_fold  =1
	let perl_nofold_packages =0
	let perl_fold_blocks = 1
	let perl_nofold_packages = 1
"	let g:Perl_NoKeyMappings = 1

	" options for minibufexpl
	let g:miniBufExplMapWindowNavVim = 1
	let g:miniBufExplMapWindowNavArrows = 1
	let g:miniBufExplMapCTabSwitchBufs = 1
	let g:miniBufExplModSelTarget = 1


	" options for VimOrganizer
	au! BufRead,BufWrite,BufWritePost,BufNewFile *.org
	au BufEnter *.org            call org#SetOrgFileType()

	" dbext profiles
	" win32
	if has("win32")
	else 
	"linux
		let g:dbext_default_profile_filesdb = ''
	endif
    " disable eclim
    let g:EclimDisabled=1
" functions

function! PlainTextFile ()
	set wrapmargin=8 
	set nolist
	set nonumber
endfunction

" maps
nmap gf :vs <cfile><CR>
nmap <silent> <F2> :set invlist<CR>:set invnumber<CR>:set invfoldenable<CR>
nmap <silent> <F3> :set invhls<CR>
nmap <silent> <F7> :TlistToggle<CR>
nmap <silent> <F6> :set invspell<CR>
set pastetoggle=<F8>

nmap <silent> <C-P> :pop<CR>


" Vundle

filetype off
call plug#begin()

 Plug 'elzr/vim-json'

 " general text object plugins
 Plug 'junegunn/vim-easy-align'
 Plug 'tpope/vim-surround'
 
 Plug 'tpope/vim-fugitive'
" Plug 'Lokaltog/vim-easymotion'
 Plug 'godlygeek/tabular'
 Plug 'plasticboy/vim-markdown'

 " Plugins for angular
 Plug 'leafgarland/typescript-vim'
 Plug 'Quramy/vim-js-pretty-template'
 Plug 'Quramy/tsuquyomi' 

 " Plugins for java
 Plug 'artur-shaik/vim-javacomplete2'

 "go plugin
 Plug 'fatih/vim-go'
 ""a tagbar
 Plug 'majutsushi/tagbar'
 " syntax checker
 Plug 'scrooloose/syntastic'

 Plug 'jiangmiao/auto-pairs'

 Plug 'scrooloose/nerdtree'

 " deoplete and deps
 Plug 'Shougo/deoplete.nvim'
 Plug 'roxma/nvim-yarp'
 Plug 'roxma/vim-hug-neovim-rpc'

 Plug 'weynhamz/vim-plugin-minibufexpl'

 Plug 'airblade/vim-gitgutter'
 Plug 'xolox/vim-misc'
 Plug 'xolox/vim-shell'
 Plug 'tomtom/quickfixsigns_vim'

 " Snippets
 Plug 'SirVer/ultisnips'
 Plug 'honza/vim-snippets'
 Plug 'jvanja/vim-bootstrap4-snippets'

 " colorscheme
 Plug 'nightsense/vimspectr'
 Plug 'jacoborus/tender.vim'

call plug#end()            " required



let g:vimspectr30curve_dark_StatusLine = 'yellow'
colorscheme tender

filetype plugin indent on    " required

" Use deoplete.
let g:deoplete#enable_at_startup = 1

" autocmds
augroup filetype
    " for plain text files
    autocmd!
	au BufNewFile,BufRead *.txt call PlainTextFile()
" for perl test files
	au BufNewFile,BufRead *.t setfiletype=perl

    autocmd FileType javascript setlocal sw=2 ts=2
    autocmd FileType json setlocal sw=2 ts=2

	autocmd BufEnter * let &titlestring = "[" . system("whoami") ."](". expand("%:t") . ")"
augroup end

augroup filetype_go
    autocmd!
    autocmd Syntax go normal zR
    au FileType go nmap <leader>r <Plug>(go-run-split)
augroup end

augroup filetype_java
    autocmd!
    autocmd Syntax java normal zR

    set noautochdir
    autocmd FileType java setlocal omnifunc=javacomplete#Complete

    "au FileType java nmap <leader>r <Plug>(go-run-split)
augroup end

if &term == "screen" || &term == "screen-256color"
    set t_ts=k
    set t_fs=\
endif
if &term == "screen" || &term == "screen-256color" || &term == "xterm"
    set title
endif

filetype plugin indent on
