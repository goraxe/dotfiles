" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/manpageview.vim	[[[1
749
" manpageview.vim : extra commands for manual-handling
" Author:	Charles E. Campbell, Jr.
" Date:		Feb 21, 2007
" Version:	16
"
" Please read :help manpageview for usage, options, etc
"
" GetLatestVimScripts: 489 1 :AutoInstall: manpageview.vim

" ---------------------------------------------------------------------
" Load Once: {{{1
if &cp || exists("g:loaded_manpageview")
 finish
endif
let g:loaded_manpageview = "v16"
let s:keepcpo            = &cpo
set cpo&vim
"DechoTabOn

" ---------------------------------------------------------------------
" Set up default manual-window opening option: {{{1
if !exists("g:manpageview_winopen")
 let g:manpageview_winopen= "hsplit"
elseif g:manpageview_winopen == "only" && !has("mksession")
 echomsg "***g:manpageview_winopen<".g:manpageview_winopen."> not supported w/o +mksession"
 let g:manpageview_winopen= "hsplit"
endif

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>ManPageView') && &kp =~ '^man\>'
  nmap <unique> K <Plug>ManPageView
endif
nmap <silent> <script> <Plug>ManPageView  :call <SID>ManPageView(1,0,expand("<cWORD>"))<CR>

com! -nargs=* -count=0	Man call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	HMan let g:manpageview_winopen="hsplit"|call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	OMan let g:manpageview_winopen="only"  |call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	RMan let g:manpageview_winopen="reuse" |call s:ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	VMan let g:manpageview_winopen="vsplit"|call s:ManPageView(0,<count>,<f-args>)

" ---------------------------------------------------------------------
" Default Variable Values: {{{1
if !exists("g:manpageview_pgm")
 let g:manpageview_pgm= "man"
endif
if !exists("g:manpageview_options")
 let g:manpageview_options= ""
endif
if !exists("g:manpageview_pgm_i")
 let g:manpageview_pgm_i     = "info"
 let g:manpageview_options_i = "--output=-"
 let g:manpageview_syntax_i  = "info"
 let g:manpageview_K_i       = "<sid>ManPageInfo(0)"
 let g:manpageview_init_i    = "call ManPageInfoInit()"

 let s:linkpat1 = '\*[Nn]ote \([^():]*\)\(::\|$\)' " note
 let s:linkpat2 = '^\* [^:]*: \(([^)]*)\)'         " filename
 let s:linkpat3 = '^\* \([^:]*\)::'                " menu
 let s:linkpat4 = '^\* [^:]*:\s*\([^.]*\)\.$'      " index
endif
if !exists("g:manpageview_pgm_pl")
 let g:manpageview_pgm_pl     = "perldoc"
 let g:manpageview_options_pl = ";-f;-q"
endif
if !exists("g:manpageview_pgm_php") && executable("links")
 let g:manpageview_pgm_php    = "links http://www.php.net/"
 let g:manpageview_nospace_php= 1
 let g:manpageview_syntax_php = "manphp"
 let g:manpageview_K_php      = "<sid>ManPagePhp()"
endif
if exists("g:manpageview_hypertext_tex") && executable("links") && !exists("g:manpageview_pgm_tex")
 let g:manpageview_pgm_tex    = "links ".g:manpageview_hypertext_tex
 let g:manpageview_lookup_tex = "<sid>ManPageTexLookup"
 let g:manpageview_K_tex      = "<sid>ManPageTex()"
endif
if has("win32") && !exists("g:manpageview_rsh")
 let g:manpageview_rsh= "rsh"
endif

" =====================================================================
"  Functions: {{{1

" ManPageView: view a manual-page, accepts three formats: {{{2
"    :call s:ManPageView(viamap,"topic")
"    :call s:ManPageView(viamap,booknumber,"topic")
"    :call s:ManPageView(viamap,"topic(booknumber)")
"
"    viamap=0: called via a command
"    viamap=1: called via a map
"    bknum   : if non-zero, then its the book number of the manpage (default=1)
"              if zero, but viamap==1, then use lastline-firstline+1
fun! s:ManPageView(viamap,bknum,...) range
"  call Dfunc("ManPageView(viamap=".a:viamap." bknum=".a:bknum.") a:0=".a:0)
  set lz
  let manpageview_fname = expand("%")
  call s:MPVSaveSettings()

  if a:0 > 0
   " fix topic
   let topic= substitute(a:1,'[^-a-zA-Z().0-9_].*$','','')
"   call Decho("a:1<".a:1."> topic<".topic."> (after fix)")
  endif

  " interpret the input arguments - set up manpagetopic and manpagebook
  if a:0 > 0 && strpart(topic,0,1) == '"'
   let topic= topic
   " merge quoted arguments:  Man "some topic here"
"   call Decho('case a:0='.a:0." strpart(".topic.",0,1)<".strpart(topic,0,1))
   let manpagetopic = strpart(topic,1)
"   call Decho("manpagetopic<".manpagetopic.">")
   if a:bknum > 0
   	let manpagebook= string(a:bknum)
   else
    let manpagebook= ""
   endif
"   call Decho("manpagebook<".manpagebook.">")
   let i= 2
   while i <= a:0
   	let manpagetopic= manpagetopic.' '.a:{i}
	if a:{i} =~ '"$'
	 break
	endif
   	let i= i + 1
   endwhile
   let manpagetopic= strpart(manpagetopic,0,strlen(manpagetopic)-1)
"   call Decho("merged quoted arguments<".manpagetopic.">")

  elseif a:0 == 0
"   call Decho('case a:0='.a:0)
   if exists("g:ManCurPosn") && has("mksession")
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn exists")
	call s:ManRestorePosn()
   else
    echomsg "***usage*** :Man topic  -or-  :Man topic nmbr"
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn doesn't exist")
   endif
   call s:MPVRestoreSettings()
"   call Dret("ManPageView")
   return

  elseif a:0 == 1
   " ManPageView("topic") -or-  ManPageView("topic(booknumber)")
"   call Decho("case a:0=".a:0." (topic  -or-  topic(booknumber))")
"   call Decho("ManPageView: a:0=".a:0." topic<".topic.">")
   if topic =~ "("
	" abc(3)
	let a1 = substitute(topic,'[-+*/;,.:]\+$','','e')
	if a1 =~ '[,"]'
     let manpagetopic= substitute(a1,'[(,"].*$','','e')
	else
     let manpagetopic= substitute(a1,'^\(.*\)(\d\+[A-Z]\=),\=.*$','\1','e')
     let manpagebook = substitute(a1,'^.*(\(\d\+\)[A-Z]\=),\=.*$','\1','e')
	endif

   else
    " ManPageView(booknumber,"topic")
    let manpagetopic= topic
    if a:viamap == 1 && a:lastline > a:firstline
     let manpagebook= string(a:lastline - a:firstline + 1)
    elseif a:bknum > 0
     let manpagebook= string(a:bknum)
	else
     let manpagebook= ""
    endif
   endif

  else
   " 3 abc  -or-  abc 3
"   call Decho("case a:0=".a:0." (3 abc  -or-  abc 3)")
   if     topic =~ '^\d\+'
    let manpagebook = topic
    let manpagetopic= a:2
   elseif a:2 =~ '^\d\+$'
    let manpagebook = a:2
    let manpagetopic= topic
   elseif topic == "-k"
"    call Decho("user requested man -k")
    let manpagetopic = a:2
    let manpagebook  = "-k"
   else
	" default: topic book
    let manpagebook = a:2
    let manpagetopic= topic
   endif
  endif
"  call Decho("manpagetopic<".manpagetopic.">")
"  call Decho("manpagebook <".manpagebook.">")

  " default program g:manpageview_pgm=="man" may be overridden
  " if an extension is matched
  if exists("g:manpageview_pgm")
   let pgm = g:manpageview_pgm
  else
   let pgm = ""
  endif
  let ext = ""
  if manpagetopic =~ '\.'
   let ext = substitute(manpagetopic,'^.*\.','','e')
  endif

  " infer the appropriate extension based on the filetype
  if ext == ""
"   call Decho("attempt to infer on filetype<".&ft.">")

   " filetype: vim
   if &ft == "vim"
   	if g:manpageview_winopen == "only"
   	 exe "help ".manpagetopic
	 only
	elseif g:manpageview_winopen == "vsplit"
   	 exe "vert help ".manpagetopic
	elseif g:manpageview_winopen == "vsplit="
   	 exe "vert help ".manpagetopic
	 wincmd =
	elseif g:manpageview_winopen == "hsplit="
   	 exe "help ".manpagetopic
	 wincmd =
	else
   	 exe "help ".manpagetopic
	endif
"    call Dret("ManPageView")
	return

   " filetype: perl
   elseif &ft == "perl"
   	let ext = "pl"

   " filetype:  php
   elseif &ft == "php"
   	let ext = "php"

   " filetype: tex
  elseif &ft == "tex"
   let ext= "tex"
   endif
  endif
"  call Decho("ext<".ext.">")

  " elide extension from manpagetopic
  if exists("g:manpageview_pgm_{ext}")
   let pgm          = g:manpageview_pgm_{ext}
   let manpagetopic = substitute(manpagetopic,'.'.ext.'$','','')
  endif
  let nospace= exists("g:manpageview_nospace_{ext}")
"  call Decho("pgm<".pgm."> manpagetopic<".manpagetopic.">")

  " special exception for info
  if a:viamap == 0 && ext == "i"
   let s:manpageview_pfx_i = "(".manpagetopic.")"
   let manpagetopic        = "Top"
"   call Decho("top-level info: manpagetopic<".manpagetopic.">")
  endif
  if exists("s:manpageview_pfx_{ext}")
   let manpagetopic= s:manpageview_pfx_{ext}.manpagetopic
  elseif exists("g:manpageview_pfx_{ext}")
   " prepend any extension-specified prefix to manpagetopic
   let manpagetopic= g:manpageview_pfx_{ext}.manpagetopic
  endif
  if exists("g:manpageview_sfx_{ext}")
   " append any extension-specified suffix to manpagetopic
   let manpagetopic= manpagetopic.g:manpageview_sfx_{ext}
  endif
  if exists("g:manpageview_K_{ext}")
   " override usual K map
"   call Decho("override K map to call ".g:manpageview_K_{ext})
   exe "nmap <silent> K :call ".g:manpageview_K_{ext}."\<cr>"
  endif
  if exists("g:manpageview_syntax_{ext}")
   " allow special-suffix extensions to optionally control syntax highlighting
   let manpageview_syntax= g:manpageview_syntax_{ext}
  else
   let manpageview_syntax= "man"
  endif

  " support for searching for options from conf pages
  if manpagebook == "" && manpageview_fname =~ '\.conf$'
   let manpagesrch = '^\s\+'.manpagetopic
   let manpagetopic= manpageview_fname
  endif
"  call Decho("manpagebook<".manpagebook."> manpagetopic<".manpagetopic.">")

  " it was reported to me that some systems change display sizes when a
  " filtering command is used such as :r! .  I record the height&width
  " here and restore it afterwards.  To make use of it, put
  "   let g:manpageview_dispresize= 1
  " into your <.vimrc>
  let dwidth  = &cwh
  let dheight = &co
"  call Decho("dwidth=".dwidth." dheight=".dheight)

  " Set up the window for the manpage display (only hsplit split etc)
  if     g:manpageview_winopen == "only"
"   call Decho("only mode")
   silent! windo w
   if !exists("g:ManCurPosn") && has("mksession")
    call s:ManSavePosn()
   endif
   " Record current file/position/screen-position
   if &ft != manpageview_syntax
    silent! only!
   endif
   enew!
  elseif g:manpageview_winopen == "hsplit"
"   call Decho("hsplit mode")
   if &ft != manpageview_syntax
    wincmd s
    enew!
    wincmd _
    3wincmd -
   else
    enew!
   endif
  elseif g:manpageview_winopen == "hsplit="
"   call Decho("hsplit= mode")
   if &ft != manpageview_syntax
    wincmd s
   endif
   enew!
  elseif g:manpageview_winopen == "vsplit"
"   call Decho("vsplit mode")
   if &ft != manpageview_syntax
    wincmd v
    enew!
    wincmd |
    20wincmd <
   else
    enew!
   endif
  elseif g:manpageview_winopen == "vsplit="
"   call Decho("vsplit= mode")
   if &ft != "man"
    wincmd v
   endif
   enew!
  elseif g:manpageview_winopen == "reuse"
   if &mod == 1
   	" file has been modified, would be lost if we re-used window.
	" Use hsplit instead.
    wincmd s
    enew!
    wincmd _
    3wincmd -
   elseif &ft != manpageview_syntax
   	setlocal bh=hide
    enew!
   else
    enew!
   endif
  else
   echohl ErrorMsg
   echo "***sorry*** g:manpageview_winopen<".g:manpageview_winopen."> not supported"
   echohl None
   sleep 2
   call s:MPVRestoreSettings()
"   call Dret("ManPageView : manpageview_winopen<".g:manpageview_winopen."> not supported")
   return
  endif

  " allow user to specify file encoding
  if exists("g:manpageview_fenc")
   exe "setlocal fenc=".g:manpageview_fenc
  endif

  " when this buffer is exited it will be wiped out
  if v:version >= 602
   setlocal bh=wipe
  endif
  let b:did_ftplugin= 2
  let $COLUMNS=winwidth(0)

  " special manpageview buffer maps
  nnoremap <buffer> <space>     <c-f>
  nnoremap <buffer> <c-]>       :call <SID>ManPageView(1,expand("<cWORD>"))<cr>

  " -----------------------------------------
  " Invoke the man command to get the manpage
  " -----------------------------------------
  " the buffer must be modifiable for the manpage to be loaded via :r!
  setlocal ma

  let cmdmod= ""
  if v:version >= 603
   let cmdmod= "silent keepjumps "
  endif

  " extension-based initialization (expected: buffer-specific maps)
  if exists("g:manpageview_init_{ext}")
   if !exists("b:manpageview_init_{ext}")
"    call Decho("exe manpageview_init_".ext."<".g:manpageview_init_{ext}.">")
    exe g:manpageview_init_{ext}
	let b:manpageview_init_{ext}= 1
   endif
  elseif ext == ""
   silent! unmap K
   nmap <unique> K <Plug>ManPageView
  endif

  " default program g:manpageview_options (empty string) may be overridden
  " if an extension is matched
  let opt= g:manpageview_options
  if exists("g:manpageview_options_{ext}")
   let opt= g:manpageview_options_{ext}
  endif
"  call Decho("opt<".opt.">")

  let cnt= 0
  while cnt < 3 && (strlen(opt) > 0 || cnt == 0)
   let cnt   = cnt + 1
   let iopt  = substitute(opt,';.*$','','e')
   let opt   = substitute(opt,'^.\{-};\(.*\)$','\1','e')
"   call Decho("iopt<".iopt."> opt<".opt.">")

   " use pgm to read/find/etc the manpage (but only if pgm is not the empty string)
   " by default, pgm is "man"
   if pgm != ""

	" ---------------------------
	" use manpage_lookup function
	" ---------------------------
   	if exists("g:manpageview_lookup_{ext}")
"	 call Decho("lookup: exe call ".g:manpageview_lookup_{ext}."(".manpagebook.",".manpagetopic.")")
	 exe "call ".g:manpageview_lookup_{ext}."(".manpagebook.",".manpagetopic.")"

    elseif has("win32") && exists("g:manpageview_server") && exists("g:manpageview_user")
"     call Decho("win32: manpagebook<".manpagebook."> topic<".manpagetopic.">")
     exe cmdmod."r!".g:manpageview_rsh." ".g:manpageview_server." -l ".g:manpageview_user." ".pgm." ".iopt." ".manpagebook." ".manpagetopic
     exe cmdmod.'silent!  %s/.\b//ge'

"   elseif has("conceal")
"    exe cmdmod."r!".pgm." ".iopt." ".manpagebook." ".manpagetopic

	"--------------------------
	" use pgm to obtain manpage
	"--------------------------
    else
     if nospace
"	  call Decho("(nospace) exe silent! ".cmdmod."r!".pgm.iopt.manpagebook.manpagetopic)
	  exe "silent! ".cmdmod."r!".pgm.iopt.manpagebook.manpagetopic
     elseif has("win32")
"      call Decho("(win32) exe silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." \"".manpagetopic."\"")
      exe "silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." \"".manpagetopic."\""
	 else
"      call Decho("(nrml) exe silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." '".manpagetopic."'")
      exe "silent! ".cmdmod."r!".pgm." ".iopt." ".manpagebook." '".manpagetopic."'"
	endif
     exe cmdmod.'silent!  %s/.\b//ge'
    endif
   endif

   " check if manpage actually found
   if line("$") != 1 || col("$") != 1
"    call Decho("manpage found")
    break
   endif
"   call Decho("manpage not found")
  endwhile

  " here comes the vim display size restoration
  if exists("g:manpageview_dispresize")
   if g:manpageview_dispresize == 1
"    call Decho("restore display size to ".dheight."x".dwidth)
    exe "let &co=".dwidth
    exe "let &cwh=".dheight
   endif
  endif

  " clean up (ie. remove) any ansi escape sequences
  silent! %s/\e\[[0-9;]\{-}m//ge
  silent! %s/\%xe2\%x80\%x90/-/ge
  silent! %s/\%xe2\%x88\%x92/-/ge
  silent! %s/\%xe2\%x80\%x99/'/ge
  silent! %s/\%xe2\%x94\%x82/ /ge

  " set up options and put cursor at top-left of manpage
  if manpagebook == "-k"
   setlocal ft=mankey
  else
   exe cmdmod."setlocal ft=".manpageview_syntax
  endif
  exe cmdmod."setlocal ro"
  exe cmdmod."setlocal noma"
  exe cmdmod."setlocal nomod"
  exe cmdmod."setlocal nolist"
  exe cmdmod."setlocal nonu"
  exe cmdmod."setlocal fdc=0"
"  exe cmdmod."setlocal isk+=-,.,(,)"
  exe cmdmod."setlocal nowrap"
  set nolz
  exe cmdmod."1"
  exe cmdmod."norm! 0"

  if line("$") == 1 && col("$") == 1
   " looks like there's no help for this topic
   q
"   call Decho("***warning*** no manpage exists for <".manpagetopic."> book=".manpagebook)
   echohl ErrorMsg
   echo "***warning*** sorry, no manpage exists for <".manpagetopic.">"
   echohl None
   sleep 2
  elseif manpagebook == ""
   exe 'file '.'Manpageview['.manpagetopic.']'
"   call Decho("setting filename<Manpageview[".manpagetopic.']>')
  else
   exe 'file '.'Manpageview['.manpagetopic.'('.manpagebook.')]'
"   call Decho("setting filename<Manpageview[".manpagetopic.'('.manpagebook.')]>')
  endif

  " if there's a search pattern, use it
  if exists("manpagesrch")
   if search(manpagesrch,'w') != 0
    exe "norm! z\<cr>"
   endif
  endif

  call s:MPVRestoreSettings()
"  call Dret("ManPageView")
endfun

" ---------------------------------------------------------------------
" MPVSaveSettings: save and standardize certain user settings {{{2
fun! s:MPVSaveSettings()

  if !exists("s:sxqkeep")
"   call Dfunc("MPVSaveSettings()")
   let s:sxqkeep           = &sxq
   let s:srrkeep           = &srr
   let s:repkeep           = &report
   let s:gdkeep            = &gd
   let s:cwhkeep           = &cwh
   let s:magickeep         = &magic
   set srr=> report=10000 nogd magic
   if &cwh < 2
    " avoid hit-enter prompts
    set cwh=2
   endif
  if has("win32") || has("win95") || has("win64") || has("win16")
   let &sxq= '"'
  else
   let &sxq= ""
  endif
"  call Dret("MPVSaveSettings")
 endif

endfun

" ---------------------------------------------------------------------
" MPV_RestoreSettings: {{{2
fun! s:MPVRestoreSettings()
  if exists("s:sxqkeep")
"   call Dfunc("MPV_RestoreSettings()")
   let &sxq    = s:sxqkeep   | unlet s:sxqkeep
   let &srr    = s:srrkeep   | unlet s:srrkeep
   let &report = s:repkeep   | unlet s:repkeep
   let &gd     = s:gdkeep    | unlet s:gdkeep
   let &cwh    = s:cwhkeep   | unlet s:cwhkeep
   let &magic  = s:magickeep | unlet s:magickeep
"   call Dret("MPV_RestoreSettings")
  endif
endfun

" ---------------------------------------------------------------------
" ManRestorePosn: restores file/position/screen-position {{{2
"                 (uses g:ManCurPosn)
fun! s:ManRestorePosn()
"  call Dfunc("ManRestorePosn()")

  if exists("g:ManCurPosn")
"   call Decho("g:ManCurPosn<".g:ManCurPosn.">")
   if v:version >= 603
    exe 'keepjumps silent! source '.escape(g:ManCurPosn,' ')
   else
    exe 'silent! source '.escape(g:ManCurPosn,' ')
   endif
   unlet g:ManCurPosn
   silent! cunmap q
  endif

"  call Dret("ManRestorePosn")
endfun

" ---------------------------------------------------------------------
" ManSavePosn: saves current file, line, column, and screen position {{{2
fun! s:ManSavePosn()
"  call Dfunc("ManSavePosn()")

  let g:ManCurPosn= tempname()
  let keep_ssop   = &ssop
  let &ssop       = 'winpos,buffers,slash,globals,resize,blank,folds,help,options,winsize'
  if v:version >= 603
   exe 'keepjumps silent! mksession! '.escape(g:ManCurPosn,' ')
  else
   exe 'silent! mksession! '.escape(g:ManCurPosn,' ')
  endif
  let &ssop       = keep_ssop
  cnoremap <silent> q call <SID>ManRestorePosn()<CR>

"  call Dret("ManSavePosn")
endfun

let &cpo= s:keepcpo
unlet s:keepcpo

" ---------------------------------------------------------------------
" ManPageInfo: {{{2
fun! s:ManPageInfo(type)
"  call Dfunc("ManPageInfo(type=".a:type.")")

  if &ft != "info"
   " restore K and do a manpage lookup for word under cursor
   setlocal kp=<sid>ManPageView
   if exists("s:manpageview_pfx_i")
    unlet s:manpageview_pfx_i
   endif
   call s:ManPageView(1,0,expand("<cWORD>"))
"   call Dret("ManPageInfo : restored K")
   return
  endif

  if !exists("s:manpageview_pfx_i")
   let s:manpageview_pfx_i= g:manpageview_pfx_i
  endif

  " -----------
  " Follow Link
  " -----------
  if a:type == 0
   " extract link
   let curline  = getline(".")
"  call Decho("curline<".curline.">")
   let ipat     = 1
   while ipat <= 4
    let link= matchstr(curline,s:linkpat{ipat})
    if link != ""
     if ipat == 2
      let s:manpageview_pfx_i = substitute(link,s:linkpat{ipat},'\1','')
      let node                = "Top"
     else
      let node                = substitute(link,s:linkpat{ipat},'\1','')
 	 endif
"   	 call Decho("ipat=".ipat."link<".link."> node<".node."> pfx<".s:manpageview_pfx_i.">")
 	 break
    endif
    let ipat= ipat + 1
   endwhile

  " ---------------
  " Go to next node
  " ---------------
  elseif a:type == 1
   let node= matchstr(getline(2),'Next: \zs[^,]\+\ze,')
   let fail= "no next node"

  " -------------------
  " Go to previous node
  " -------------------
  elseif a:type == 2
   let node= matchstr(getline(2),'Prev: \zs[^,]\+\ze,')
   let fail= "no previous node"

  " ----------
  " Go up node
  " ----------
  elseif a:type == 3
   let node= matchstr(getline(2),'Up: \zs.\+$')
   let fail= "no up node"

  " --------------
  " Go to top node
  " --------------
  elseif a:type == 4
   let node= "Top"
  endif

  " use ManPageView() to view selected node
  if node == ""
   echohl ErrorMsg
   echo "***sorry*** ".fail
   echohl None
   sleep 2
  else
"   call Decho("node<".node.">")
   call s:ManPageView(1,0,node.".i")
  endif

"  call Dret("ManPageInfo")
endfun

" ---------------------------------------------------------------------
" ManPageInfoInit: {{{2
fun! ManPageInfoInit()
"  call Dfunc("ManPageInfoInit()")

  " some mappings to imitate the default info reader
  nmap    <buffer>          <cr> K
  noremap <silent> <buffer> >    :call <SID>ManPageInfo(1)<cr>
  noremap <silent> <buffer> n    :call <SID>ManPageInfo(1)<cr>
  noremap <silent> <buffer> <    :call <SID>ManPageInfo(2)<cr>
  noremap <silent> <buffer> p    :call <SID>ManPageInfo(2)<cr>
  noremap <silent> <buffer> u    :call <SID>ManPageInfo(3)<cr>
  noremap <silent> <buffer> t    :call <SID>ManPageInfo(4)<cr>
  noremap <silent> <buffer> ?    :he manpageview-info<cr>
  noremap <silent> <buffer> d	 :call <SID>ManPageView(0,0,"dir.i")<cr>
  noremap <silent> <buffer> <BS> <C-B>
  noremap <silent> <buffer> <Del> <C-B>
  noremap <silent> <buffer> <Tab> :call <SID>NextInfoLink()<CR>

"  call Dret("ManPageInfoInit")
endfun

" NextInfoLink: {{{2
fun! s:NextInfoLink()
    let ln = search('\('.s:linkpat1.'\|'.s:linkpat2.'\|'.s:linkpat3.'\|'.s:linkpat4.'\)', 'w')
    if ln == 0
		echohl ErrorMsg
	   	echo '***sorry*** no links found' 
	   	echohl None
		sleep 2
    endif
endfun

" ---------------------------------------------------------------------
" ManPageTex: {{{2
fun! s:ManPageTex()
  let topic= '\'.expand("<cWORD>")
"  call Dfunc("ManPageTex() topic<".topic.">")
  call s:ManPageView(1,0,topic)
"  call Dret("ManPageTex")
endfun

" ---------------------------------------------------------------------
" ManPageTexLookup: {{{2
fun! ManPageTexLookup(book,topic)
"  call Dfunc("ManPageTexLookup(book<".a:book."> topic<".a:topic.">)")
"  call Dret("ManPageTexLookup ".lookup)
endfun

" ---------------------------------------------------------------------
" ManPagePhp: {{{2
fun! s:ManPagePhp()
  let topic=substitute(expand("<cWORD>"),'()','.php','e')
"  call Dfunc("ManPagePhp() topic<".topic.">")
  call s:ManPageView(1,0,topic)
"  call Dret("ManPagePhp")
endfun

" ---------------------------------------------------------------------
" Modeline: {{{1
" vim: ts=4 fdm=marker
syntax/man.vim	[[[1
108
" Vim syntax file
"  Language:	Manpageview
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Jun 28, 2006
"  Version:    	4
"
"  History:
"    2: * Now has conceal support
"       * complete substitute for distributed <man.vim>
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
if !has("conceal")
 " hide control characters, especially backspaces
 if version >= 600
  run! syntax/ctrlh.vim
 else
  so <sfile>:p:h/ctrlh.vim
 endif
endif

syn case ignore
" following four lines taken from Vim's <man.vim>:
syn match  manReference		"\f\+([1-9][a-z]\=)"
syn match  manTitle		"^\f\+([0-9]\+[a-z]\=).*"
syn match  manSectionHeading	"^[a-z][a-z ]*[a-z]$"
syn match  manOptionDesc	"^\s*[+-][a-z0-9]\S*"

syn match  manSectionHeading	"^\s\+[0-9]\+\.[0-9.]*\s\+[A-Z].*$"	contains=manSectionNumber
syn match  manSectionNumber	"^\s\+[0-9]\+\.[0-9]*"			contained
syn region manDQString		start='[^a-zA-Z"]"[^", )]'lc=1		end='"'		end='^$' contains=manSQString
syn region manSQString		start="[ \t]'[^', )]"lc=1		end="'"		end='^$'
syn region manSQString		start="^'[^', )]"lc=1			end="'"		end='^$'
syn region manBQString		start="[^a-zA-Z`]`[^`, )]"lc=1		end="[`']"	end='^$'
syn region manBQString		start="^`[^`, )]"			end="[`']"	end='^$'
syn region manBQSQString	start="``[^),']"			end="''"	end='^$'
syn match  manBulletZone	"^\s\+o\s"				transparent contains=manBullet
syn case match

syn keyword manBullet		o					contained
syn match   manBullet		"\[+*]"					contained
syn match   manSubSectionStart	"^\*"					skipwhite nextgroup=manSubSection
syn match   manSubSection	".*$"					contained
syn match   manOptionWord	"\s[+-]\a\+\>"

if has("conceal")
 setlocal conc=3
 syn match manSubTitle		/\(.\b.\)\+/	contains=manSubTitleHide
 syn match manUnderline		/\(_\b.\)\+/	contains=manSubTitleHide
 syn match manSubTitleHide	/.\b/		conceal contained
endif

" my RH8 linux's man page puts some pretty oddball characters into its
" manpages...
silent! %s/’/'/ge
silent! %s/−/-/ge
silent! %s/‐$/-/e
silent! %s/‘/`/ge
silent! %s/‐/-/ge
norm! 1G

set ts=8

if version >= 508 || !exists("did_man_syn_inits")
  if version < 508
    let did_man_syn_inits = 1
    com! -nargs=+ HiLink hi link <args>
  else
    com! -nargs=+ HiLink hi def link <args>
  endif

  HiLink manTitle		Title
"  HiLink manSubTitle		Statement
  HiLink manUnderline		Type
  HiLink manSectionHeading	Statement
  HiLink manOptionDesc		Constant

  HiLink manReference		PreProc
  HiLink manSectionNumber	Number
  HiLink manDQString		String
  HiLink manSQString		String
  HiLink manBQString		String
  HiLink manBQSQString		String
  HiLink manBullet		Special
  if has("win32") || has("win95") || has("win64") || has("win16")
   if &shell == "bash"
    hi manSubSectionStart	term=NONE      cterm=NONE      gui=NONE      ctermfg=black ctermbg=black guifg=navyblue guibg=navyblue
    hi manSubSection		term=underline cterm=underline gui=underline ctermfg=green guifg=green
    hi manSubTitle		term=NONE      cterm=NONE      gui=NONE      ctermfg=cyan  ctermbg=blue  guifg=cyan     guibg=blue
   else
    hi manSubSectionStart	term=NONE      cterm=NONE      gui=NONE      ctermfg=black ctermbg=black guifg=black    guibg=black
    hi manSubSection		term=underline cterm=underline gui=underline ctermfg=green guifg=green
    hi manSubTitle		term=NONE      cterm=NONE      gui=NONE      ctermfg=cyan  ctermbg=blue  guifg=cyan     guibg=blue
   endif
  else
   hi manSubSectionStart	term=NONE      cterm=NONE      gui=NONE      ctermfg=black ctermbg=black guifg=navyblue guibg=navyblue
   hi manSubSection		term=underline cterm=underline gui=underline ctermfg=green guifg=green
   hi manSubTitle		term=NONE      cterm=NONE      gui=NONE      ctermfg=cyan  ctermbg=blue  guifg=cyan     guibg=blue
  endif

  delcommand HiLink
endif

let b:current_syntax = "man"

" vim:ts=8
syntax/mankey.vim	[[[1
45
" Vim syntax file
"  Language:	Man keywords page
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Sep 26, 2005
"  Version:    	1
"    (used by plugin/manpageview.vim)
"
"  History:
"    1:	The Beginning
" ---------------------------------------------------------------------
"  Initialization:
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
syn clear

" ---------------------------------------------------------------------
"  Highlighting Groups: matches, ranges, and keywords
syn match mankeyTopic	'^\S\+'		skipwhite nextgroup=mankeyType,mankeyBook
syn match mankeyType	'\[\S\+\]'	contained skipwhite nextgroup=mankeySep,mankeyBook contains=mankeyTypeDelim
syn match mankeyTypeDelim	'[[\]]'	contained
syn region mankeyBook	matchgroup=Delimiter start='(' end=')'	contained skipwhite nextgroup=mankeySep
syn match mankeySep		'\s\+-\s\+'	

" ---------------------------------------------------------------------
"  Highlighting Colorizing Links:
if version >= 508 || !exists("did_mankey_syn_inits")
 if version < 508
  let did_mankey_syn_inits = 1
  command! -nargs=+ HiLink hi link <args>
 else
  command! -nargs=+ HiLink hi def link <args>
 endif

 HiLink mankeyTopic		Statement
 HiLink mankeyType		Type
 HiLink mankeyBook		Special
 HiLink mankeyTypeDelim	Delimiter
 HiLink mankeySep		Delimiter

 delc HiLink
endif
let b:current_syntax = "mankey"
syntax/info.vim	[[[1
32
" Info.vim : syntax highlighting for info
"  Language:	info
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Aug 09, 2006
"  Version:		2a	NOT RELEASED
" syntax highlighting based on Slavik Gorbanyov's work
let g:loaded_syntax_info= "v1"

syn clear
syn case match
syn match  infoMenuTitle	/^\* Menu:/hs=s+2
syn match  infoTitle		/^[A-Z][0-9A-Za-z `',/&]\{,43}\([a-z']\|[A-Z]\{2}\)$/
syn match  infoTitle		/^[-=*]\{,45}$/
syn match  infoString		/`[^`]*'/
syn region infoLink			start=/\*[Nn]ote/ end=/::/
syn match  infoLink			/\*[Nn]ote \([^():]*\)\(::\|$\)/
syn match  infoLink			/^\* \([^:]*\)::/hs=s+2
syn match  infoLink			/^\* [^:]*: \(([^)]*)\)/hs=s+2
syn match  infoLink			/^\* [^:]*:\s\+[^(]/hs=s+2,he=e-2
syn region infoHeader		start=/^File:/ end="$" contains=infoHeaderLabel
syn match  infoHeaderLabel	/\<\%(File\|Node\|Next\|Up\):\s/ contained

if !exists("g:did_info_syntax_inits")
  let g:did_info_syntax_inits = 1
  hi def link infoMenuTitle		Title
  hi def link infoTitle			Comment
  hi def link infoLink			Directory
  hi def link infoString		String
  hi def link infoHeader		infoLink
  hi def link infoHeaderLabel	Statement
endif
" vim: ts=4
syntax/manphp.vim	[[[1
73
" Vim syntax file
"  Language:	Man page syntax for php
"  Maintainer:	Charles E. Campbell, Jr.
"  Last Change:	Dec 29, 2005
"  Version:    	1
syn clear

let b:current_syntax = "manphp"

syn keyword manphpKey			Description Returns
syn match   manphpFunction			"\<\S\+\ze\s*--"	skipwhite nextgroup=manphpDelimiter
syn match   manphpSkip				"^\s\+\*\s*\S\+\s*"
syn match   manphpSeeAlso			"\<See also\>"		skipwhite skipnl nextgroup=manphpSeeAlsoList
syn match   manphpSeeAlsoSep	contained	",\%( and\)\="		skipwhite skipnl nextgroup=manphpSeeAlsoList,manphpSeeAlsoSkip
syn match   manphpSeeAlsoList	contained	"\s*\zs[^,]\+\ze\%(,\%( and \)\=\)"	skipwhite skipnl nextgroup=manphpSeeAlsoSep
syn match   manphpSeeAlsoList	contained  	"\s*\zs[^,.]\+\ze\."
syn match   manphpSeeAlsoSkip	contained	"^\s\+\*\s*\S\+\s*"     skipwhite skipnl nextgroup=manphpSeeAlsoList
syn match   manphpDelimiter	contained	"\s\zs--\ze\s"		skipwhite nextgroup=manphpDesc
syn match   manphpDesc		contained	".*$"
syn match   manphpUserNote			"User Contributed Notes"
syn match   manphpEditor			"\[Editor's Note:.\{-}]"
syn match   manphpUser				"\a\+ at \a\+ dot .*$"
syn match   manphpFuncList			"PHP Function List"

hi link manphpKey		Title
hi link manphpFunction		Function
hi link manphpDelimiter		Delimiter
hi link manphpDesc		manphpFunction
hi link manphpSeeAlso		Title
hi link manphpSeeAlsoList	PreProc
hi link manphpUserNote		Title
hi link manphpEditor		Special
hi link manphpUser		Search
hi link manphpSeeAlsoSkip	Ignore
hi link manphpSkip		Ignore
hi link manphpFuncList		Title

" cleanup
if !exists("g:manphp_nocleanup")
 set mod ma noro
 %s/\[\d\+]//ge
 %s/_\{2,}/__/ge
 %s/\<\%(add a note\)\+\>//ge
 1
 if search('(PHP','W')
  norm! k
  1,.d
 endif
 if search('\<References\>','W')
  /\<References\>/,$d
 endif
 if search('\<Description\>','w')
  exe '%s/^.*\%'.virtcol(".").'v//e'
  g/^\s\s\*\s/s/^.*$//
 endif
 %s/^\s*\(User Contributed Notes\)/\1/e
 %s/^\s*\(Returns\|See also\)\>/\1/e
 $
 if search('\S','bW')
  norm! j
  if line(".") != line("$")
   silent! .,$d
  endif
 endif
 if search('PHP Function List')
  if line(".") != 1
   1,.-1d
  endif
 endif
 set nomod noma ro
endif

" vim:ts=8
doc/manpageview.txt	[[[1
335
*manpageview.txt*	Man Page Viewer			Sep 26, 2006

Author:  Charles E. Campbell, Jr.  <NdrchipO@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2004-2005 by Charles E. Campbell, Jr.	*manpageview-copyright*
           The VIM LICENSE applies to ManPageView.vim and ManPageView.txt
           (see |copyright|) except use "ManPageView" instead of "Vim"
	   no warranty, express or implied.  use at-your-own-risk.

==============================================================================
1. Contents				*manpageview* *manpageview-contents*

	1. Contents.................................: |manpageview-contents|
	2. ManPageView Usage........................: |manpageview-usage|
	     General Format.........................: |manpageview-format|
	     Man....................................: |manpageview-man|
	     Opening Style..........................: |manpageview-open|
	     K Map..................................: |manpageview-K|
	     Perl...................................: |manpageview-perl|
	     Info...................................: |manpageview-info|
	     Php....................................: |manpageview-php|
	     Extending ManPageView..................: |manpageview-extend|
	3. ManPageView Options......................: |manpageview-options|
	4. ManPageView History......................: |manpageview-history|

==============================================================================
2. ManPageView Usage					*manpageview-usage*

        GENERAL FORMAT					*manpageview-format*

		(command) :[count][HORV]Man [topic] [booknumber]
		(map)     [count]K

	MAN						*manpageview-man*
>
	:[count]Man topic
	:Man topic booknumber
	:Man booknumber topic
	:Man topic(booknumber)
	:Man      -- will restore position prior to use of :Man
	             (only for g:manpageview_winopen == "only")
<
	Put cursor on topic, press "K" while in normal mode.
	(This works if (a) you've not mapped some other key
	to <Plug>ManPageView, and (b) if |keywordprg| is "man",
	which it is by default)

	If a count is present (ie. 7K), the count will be used
	as the booknumber.

	If your "man" command requires options, you may specify them
	with the g:manpageview_options variable in your <.vimrc>.


	OPENING STYLE				*manpageview-open*

	In addition, one may specify open help and specify an 
	opening style (see g:manpageview_winopen below): >

		:[count]HMan topic     -- g:manpageview_winopen= "hsplit"
		:[count]VMan topic     -- g:manpageview_winopen= "vsplit"
		:[count]OMan topic     -- g:manpageview_winopen= "osplit"
		:[count]RMan topic     -- g:manpageview_winopen= "reuse"
<
	To support perl, manpageview now can switch to using perldoc
	instead of man.  In fact, the facility is generalized to
	allow multiple help viewing systems.

	K MAP					*manpageview-K*
>
		[count]K
<
	ManPageView also supports the use of "K", as a map, to
	invoke ManPageView.  The topic is taken from the word
	currently under the cursor.

	PERL					*manpageview-perl*

	For perl, the following command, >
		:Man sprintf.pl
<	will bring up the perldoc version of sprintf.  The perl
	support includes a "path" of options to use with perldoc: >
		g:manpageview_options_pl= ";-f;-q"
<	Thus just the one suffix (.pl) with manpageview handles
	embedded perl documentation, perl builtin functions, and
	perl FAQ keywords.

	If the filetype is "perl", which is determined by vim
	for syntax highlighting, the ".pl" suffix may be dropped.
	For example, when editing a "abc.pl" file, >
		:Man sprintf
<	will return the perl  help for sprintf.

	INFO					*manpageview-info*

	Info pages are supported by appending a ".i" suffix: >
		:Man info.i
<	A number of maps are provided: >
		MAP	EFFECT
		> n	go to next node
		< p	go to previous node
		d       go to the top-level directory
		u	go to up node
		t	go to top node
		H	give help
		<bs>    go up one page
		<del>   go up one page
		<tab>   go to next hyperlink
<
	PHP					*manpageview-php*

	For php help, Manpageview uses links to get help from
	http://www.php.net (by default).  The filetype as determined
	for syntax highlighting is used to signal manpageview to use
	php help.  As an example, >
		:Man bzopen
<	will get help for bzopen for php.

	EXTENDING MANPAGEVIEW			*manpageview-extend*

	To extend manpageview to handle other documentation systems,
	manpageview has some special variables with a common extension: >

		g:manpageview_pgm_{ext}
		g:manpageview_options_{ext}
		g:manpageview_sfx_{ext}
<
	For perl, the {ext} is ".pl", and the variables are set to: >

     	     let g:manpageview_pgm_pl     = "perldoc"
     	     let g:manpageview_options_pl = ";-f;-q"
<
	For info, that {ext} is ".i", and the extension variables are
	set to: >

     	     let g:manpageview_pgm_i     = "info"
     	     let g:manpageview_options_i = "--output=-"
     	     let g:manpageview_syntax_i  = "info"
     	     let g:manpageview_K_i       = "<sid>ManPageInfo(0)"
     	     let g:manpageview_init_i    = "call ManPageInfoInit()"
<
	The help on |manpageview_extend| covers these variables in more
	detail.


==============================================================================
3. ManPageView Options					*manpageview-options*

	g:manpageview_options : extra options that will be passed on when
	                        invoking the man command
	  examples:
	            let g:manpageview_options= "-P 'cat -'"
	            let g:manpageview_options= "-c"
	            let g:manpageview_options= "-Tascii"
	
	g:manpageview_pgm : by default, its "man", but it may be changed
		     by the user.  This program is what is called to actually
		     extract the manpage.

	g:manpageview_winopen : may take on one of six values:

	   "only"    man page will become sole window.
	             Side effect: All windows' contents will be saved first!  (windo w)
	             Use :q to terminate the manpage and restore the window setup.
	             Note that mksession is used for this option, hence the
	             +mksession configure-option is required.
	   "hsplit"  man page will appear in a horizontally          split window (default)
	   "vsplit"  man page will appear in a vertically            split window
	   "hsplit=" man page will appear in a horizontally & evenly split window
	   "vsplit=" man page will appear in a vertically   & evenly split window
	   "reuse"   man page will re-use current window.  Use <ctrl-o> to return.
"                    (for the reuse option, thanks go to Alan Schmitt)
	
	g:manpageview_server : for WinNT; uses rsh to read manpage remotely
	g:manpageview_user   : use given server (host) and username
	  examples:
	            let g:manpageview_server= "somehostname"
	            let g:manpageview_user  = "username"

	g:manpageview_init_{ext}:			*manpageview_extend*
	g:manpageview_K_{ext}:
	g:manpageview_options_{ext}:
	g:manpageview_pfx_{ext}:
	g:manpageview_pgm_{ext}:
	g:manpageview_sfx_{ext}:
	g:manpageview_syntax_{ext}:

		With these options, one may specify an extension on a topic
		and have a special program and customized options for that
		program used instead of man itself.  As an example, consider
		perl: >

			let g:manpageview_pgm_pl = "perldoc"
			let g:manpageview_options= ";-f;-q"
<
		Note that, for perl, the options consist of a sequence of
		options to be tried, separated by semi-colons.

		The g:manpageview_init_{ext} specifies a function to be called
		for initialization.  The info handler, for example, uses this
		function to specify buffer-local maps.

		The g:manpageview_K_{ext} specifies a function to be invoked
		when the "K" key is tapped.  By default, it calls
		s:ManPageView().

		The g:manpageview_options_{ext} specifies what options are
		needed.

		The g:manpageview_pfx_{ext} specifies a prefix to prepend to
		the nominal manpage name.

		The g:manpageview_pgm_{ext} specifies which program to run for
		help.

		The g:manpageview_sfx_{ext} specifies a suffix to append to
		the nominal manpage name.  Without this last option, the
		provided suffix (ie. Man sprintf.pl 's  ".pl") will be elided.
		With this option, the g:manpageview_sfx_{ext} will be
		appended.

		The g:manpageview_syntax_{ext} specifies a highlighting file
		to be used for this particular extension type.

	You may map some key other than "K" to invoke ManPageView; as an
	example: >
		nmap V <Plug>ManPageView
<	Put this in your <.vimrc>.


==============================================================================
4. ManPageView History				*manpageview-history* {{{1

	Thanks go to the various people who have contributed changes,
	pointed out problems, and made suggestions!
             
	v16: Jun 28, 2006  * bypasses sxq with '"' for windows internally
	     Sep 26, 2006  * implemented <count>K to look up a topic
	                     under the cursor but in the <count>-th book
	     Nov 21, 2006  * removed s:mank related code; man -k being
	                     handled without it.
	     Dec 04, 2006  * added fdc=0 to manpageview settings bypass
	     Feb 21, 2007  * removed modifications to isk; instead,
	                     manpageview attempts to fix the topic and
			     uses expand("<cWORD>") instead:w
	v15: Jan 23, 2006  * works around nomagic option
	                   * works around cwh=1 to avoid Hit-Enter prompts
	     Feb 13, 2006  * the test for keywordprg was for "man"; now its
	                     for a regular expression "^man\>" (so its
	        	     immune to the use of options)
	     Apr 11, 2006  * HMan, OMan, VMan, Rman commands implemented
	     Jun 27, 2006  * escaped any spaces coming from tempname()
	v14: Nov 23, 2005  * "only" was occasionally issuing an "Already one
	                     window" message, which is now prevented
	     Nov 29, 2005  * Aaron Griffin found that setting gdefault
	        	     gave manpageview problems with ctrl-hs.  Fixed.
	     Dec 16, 2005  * Suresh Govindachar asked about letting
	                     manpageview also handle perldoc -q manpages.
	        	     IMHO this was getting cumbersome, so I extended
	        	     opt to allow a semi-colon separated "path" of
	        	     up to three options to try.
	     Dec 20, 2005  * In consultation with Gareth Oakes, manpageview
	                     needed some quoting and backslash-fixes to work
	        	     properly with windows and perldoc.
	     Dec 29, 2005  * added links-based help for php functions
            
	v13: Jul 19, 2005  * included niebie's changes to manpageview -
	                     <bs>, <del> to scroll one page up,
	        	     <tab> to go to the next hyperlink
	        	     d     to go to the top-level directory
	        	     and some bugfixes ([] to \[ \], and redirecting
	        	     stderr to /dev/null by default)
	     Aug 17, 2005  * report option workaround
	     Sep 26, 2005  * :Man -k  now uses "man -k" to generate a keyword
	                     listing
	        	   * included syntax/man.vim and syntax/mankey.vim
	v12: Jul 11, 2005  unmap K was causing "noise" when it was first
			   used.  Fixed.
	v11: * K now <buffer>-mapped to call ManPageView() 
	v10: * support for perl/perldoc:
	      g:manpageview_{ pgm | options | sfx }_{ extension }
	    * support for info: g:manpageview_{ K | pfx | syntax }
	    * configuration option drilling -- if you're in a
	      *.conf file, pressing "K" atop an option will go
	      to the associated help page and option, if there's
	      help for that configuration file
	v9: * for vim versions >= 6.3, keepjumps is used to reduce the
	      impact on the jumplist
	    * manpageview now turns off linewrap for the manpage, since
	      re-formatting doesn't seem to work usually.
	    * apparently some systems resize the [g]vim display when 
	      any filter is used, including manpageview's :r!... .
	      Setting g:manpageview_dispresize=1 will force retention
	      of display size.
	    * before mapping K to use manpageview, a check that
	      keywordprg is "man" is also made. (tnx to Suresh Govindachar)
	v8: * apparently bh=wipe is "new", so I've put a version
	      test around that setting to allow older vim's to avoid
	      an error message
	    * manpageview now turns numbering off in the manpage buffer (nonu)
	v7: * when a manpageview window is exit'd, it will be wiped out
	      so that it doesn't clutter the buffer list
	    * when g:manpageview_winopen was "reuse", the manpage would
	      reuse the window, even when it wasn't a manpage window.
	      Manpageview will now use hsplit if the window was marked
	      "modified"; otherwise, the associated buffer will be marked
	      as "hidden" (so that its still available via the buffer list)
	v6: * Erik Remmelzwal provided a fix to the g:manpageview_server
	      support for NT
	    * implemented Erik's suggestion to re-use manpage windows
	    * Nathan Huizinga pointed out, <cWORD> was picking up too much for
	      the K map. <cword> is now used
	    * Denilson F de Sa suggested that the man-page window be set as
	      readonly and nonmodifiable

	v5: includes g:manpageview_winmethod option (only, hsplit, vsplit)

	v4: Erik Remmelzwaal suggested including, for the benefit of NT users,
	    a command to use rsh to read the manpage remotely.  Set
	    g:manpageview_server to hostname  (in your <.vimrc>)
	    g:manpageview_user   to username

	v3: * ignores (...) if it contains commas or double quotes.  elides
	      any commas, colons, and semi-colons at end

	    * g:manpageview_options supported

	v2: saves current session prior to invoking man pages :Man    will
	    restore session.  Requires +mksession for this new command to
	    work.

	v1: the epoch

==============================================================================
vim:tw=78:ts=8:ft=help:fdm=marker
