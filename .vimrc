" vim: et sw=2 ts=2 foldmethod=marker

" {{{ settings 
set hidden
set cmdheight=2
set shortmess+=c


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

" wildmenu
set wildmode=longest,list,full
set wildmenu

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


" }}} 
" {{{ Plugin options
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

" }}}
" {{{ maps
nmap gf :vs <cfile><CR>
nmap <silent> <F2> :set invlist<CR>:set invnumber<CR>:set invfoldenable<CR>
nmap <silent> <F3> :set invhls<CR>
nmap <silent> <F7> :NERDTreeToggle<CR>:TagbarToggle<CR>
nmap <silent> <F6> :set invspell<CR>
set pastetoggle=<F8>

nmap <silent> <C-P> :pop<CR>
" }}}
" {{{ Plugins

filetype off
call plug#begin()


" {{{ Utilites

  Plug 'airblade/vim-rooter'
  Plug 'universal-ctags/ctags'
  Plug 'craigemery/vim-autotag'
  Plug 'xolox/vim-easytags'
  Plug 'ruanyl/coverage.vim'
  Plug 'bkad/CamelCaseMotion'
  Plug 'jiangmiao/auto-pairs'
  Plug 'gyim/vim-boxdraw'

  Plug 'tpope/vim-commentary'

  " general text object plugins
  Plug 'junegunn/vim-easy-align'
  Plug 'tpope/vim-surround'
" }}}

" {{{ statusline
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'edkolev/tmuxline.vim'
" }}}

  Plug 'elzr/vim-json'
" Language pack
 Plug 'sheerun/vim-polyglot'

 " Organisation and Todo
 Plug 'jceb/vim-orgmode'


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
 "Plug 'fatih/vim-go'
 Plug 'nsf/gocode', { 'rtp': 'vim', 'do': '~/.vim/plugged/gocode/vim/symlink.sh'  }
 Plug 'zchee/deoplete-go', { 'do': 'make' }
 Plug 'Shougo/vimshell.vim'
 Plug 'Shougo/vimproc.vim', {'do' : 'make'}
 Plug 'sebdah/vim-delve'

 " coc
 Plug 'neoclide/coc.nvim', { 'branch': 'release'  }
 Plug 'josa42/coc-go', {'do': 'yarn install --frozen-lockfile'}

 "a tagbar
 Plug 'majutsushi/tagbar'
 " syntax checker
 Plug 'scrooloose/syntastic'


 Plug 'scrooloose/nerdtree'
 Plug 'Xuyuanp/nerdtree-git-plugin'
 Plug 'ryanoasis/vim-devicons'

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
" Plug 'SirVer/ultisnips'
 Plug 'honza/vim-snippets'
 Plug 'jvanja/vim-bootstrap4-snippets'

 " colorscheme
 Plug 'nightsense/vimspectr'
 Plug 'jacoborus/tender.vim'
 Plug 'lifepillar/vim-solarized8'

call plug#end()            " required
" }}}
" {{{ Plugin Settings
" {{{
"map <Leader>ap 
let g:AutoPairsShortcutToggle ='<leader>ap'
" }}}
" {{{ CamelCaseMotion 
let g:camelcasemotion_key = '<leader>'
" }}}
" {{{ vimsectr 
let g:vimspectr30curve_dark_StatusLine = 'yellow'
" }}}
" {{{ easy-align 
   " Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign) 
" }}}
" {{{ go-vim

    let g:go_code_completion_enabled = 0
    let g:go_def_mapping_enabled     = 0
    let g:go_textobj_enabled         = 0

" }}}
" {{{ deoplete.
let g:deoplete#enable_at_startup = 0
" }}}
" {{{ JavaComplete
let g:JavaComplete_GradleExecutable = 'gradle'
" }}}
" {{{ coc 
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()


" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <C-d> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <C-d> <Plug>(coc-range-select)
xmap <silent> <C-d> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

"{{{
 let g:airline#extensions#coc#enabled = 1
"}}}

" coc }}}

"{{{ tagbar

let g:tagbar_compact = 1

"}}}

"{{{ airline
let g:airline_powerline_fonts=1

if (has("termguicolors"))
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum""]"
endif

let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : [ '#{prefix}', '#{pane_current_path}' ],
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W', '#F'],
      \'y'    : ['%R', '%a', '%Y'],
      \'z'    : '#H'}

"}}}

" Plugin Settings }}}
" {{{ autocmds
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

augroup filetype_ts
    autocmd!
    autocmd Filetype typescript normal zR
    autocmd FileType typescript setlocal sw=2 ts=2
augroup end
" }}}
" {{{ final settings
if &term == "screen" || &term == "screen-256color"
    set t_ts=k
    set t_fs=\
endif
if &term == "screen" || &term == "screen-256color" || &term == "xterm"
    set title
endif

filetype plugin indent on
"colorscheme tender
colorscheme solarized8
set background=dark
" }}}
