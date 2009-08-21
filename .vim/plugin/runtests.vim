" Perl Run Tests
" Kent Cowgill - kent at c2group dot net

function! TestFileName ()
  " Sets the test file name a $CWD/t/$FILE_BASE.t
  call TestFileDir ()
  if ! exists( "s:testfile" )
    let s:testfile = "t/" . expand( "%:r" ) . ".t"
  endif
  if ! filereadable( s:testfile )
    silent! exe "!touch " . s:testfile | redraw!
  endif
endfunction

function! TestFileDir ()
  " Attempts to create a t/ subdirectory of the $CWD.
  if ! ( finddir( "t" ) == "t" )
    if exists( "*mkdir" )
      call mkdir( "t" )
    else
      silent! exe "!mkdir t" | redraw!
    endif
  endif
endfunction

function! GenerateTestStub ()
  " This is the fun one that does all the work of doing its best to create
  " stub test functions.
  if ! exists( "s:testTemplate" )
    let s:testTemplate = [
          \'#!/usr/bin/perl',
          \'',
          \'use strict;',
          \'use warnings;',
          \'',
          \'use Test::More qw/no_plan/;',
          \''
        \]
  endif
  if exists( "s:thisPackage" )
    unlet s:thisPackage
  endif
  if ! exists( "s:fileFuncList" )
    let s:fileFuncList = []
  endif
  if ! exists( "s:fileTestList" )
    let s:fileTestList = []
  endif
  call TestFileName ()
  if ! ( getfsize( s:testfile ) > 0 )
    " filesize is zero, must be no tests
    let s:fileType = expand( "%:e" )
    let s:thisFile = expand( "%" )
    if s:fileType == "pl"
      call add( s:fileTestList, "BEGIN: { require_ok( '" . s:thisFile . "' ); }" )
      call add( s:fileTestList, "" )
    elseif s:fileType == "pm"
      "echo "dealing with a module"
    else
      "echo "Filetype not known"
    endif
    for n in getbufline( bufname( "%" ), 1, "$" )
      " find package names
      let s:pkgMatch = matchlist( n, 'package\s\+\(\(\w\|:\)\+\);' )
      if len( s:pkgMatch ) > 0
        let s:mypkgname = get( s:pkgMatch, 1 )
        if ! ( s:mypkgname == "0" )
          let s:thisPackage = s:mypkgname
          let s:pkgHierarchy = split( s:thisPackage, '::' )
          let s:pkgHierCount = len( s:pkgHierarchy )
          if s:pkgHierCount > 1
            let s:pkgUseHier = join( repeat( [ '..' ], s:pkgHierCount - 1 ), "/" )
            call add( s:fileTestList, "use lib '" . s:pkgUseHier . "';" )
            call add( s:fileTestList, "" )
          endif
          call add( s:fileTestList, "BEGIN: { use_ok( '" . s:thisPackage . "' ); }" )
          call add( s:fileTestList, "" )
        endif
      endif
      " find subroutines declared
      let s:subMatch = matchlist( n, 'sub\s\+\(\w\+\)\s\{0,}{\?', 0 )
      let s:mysubname = get( s:subMatch, 1 )
      if ! ( s:mysubname == "0" )
        if s:mysubname == "new"
          if exists( "s:thisPackage" )
            call add( s:fileTestList, "ok( my $obj = " . s:thisPackage . "->new(), 'can create object " . s:thisPackage . "' );" )
            call add( s:fileTestList, "isa_ok( $obj, '" . s:thisPackage . "', 'object $obj' );" )
            call add( s:fileTestList, "" )
          endif
        else
          call add( s:fileFuncList, s:mysubname )
        endif
      endif
    endfor
    if exists( "s:thisPackage" )
      let s:thisObj = '$obj->'
    else
      let s:thisObj = ''
    endif
    let s:tests = map( s:fileFuncList, '"ok( " . s:thisObj . v:val . "(), ''can call " . v:val . "()'' );" ' )
    let s:testFileList = s:testTemplate + s:fileTestList + s:tests
    let s:result = writefile( s:testFileList, s:testfile )
    echo "Test stub written to file: " . s:testfile
  endif
endfunction

function! SplitTestWindow ()
  " Silly little function to open a split buffer to the testfile for the
  " bottom (by default) 8 rows of the window.
  call TestFileName ()
  let s:testWindowSize = exists( "g:testWindowSize" ) ? g:testWindowSize : 8
  let s:save_sb = &splitbelow
    set splitbelow
    exe s:testWindowSize . "split " . s:testfile
  let &splitbelow = s:save_sb
endfunction

function! RunTests ()
  call TestFileName ()
  " I don't like how this currently works.  It seems the quickfix (from cfile)
  " takes you to the .t file, and no reliable way to get back to the primary
  " (the file being tested) window/buffer.
  " I also don't like leaving the errorfile sitting around.
  if filereadable( s:testfile ) && getfsize( s:testfile ) > 0
    echo system( "prove -lv " . s:testfile . " 2>&1 | tee " . &errorfile )
    "cfile
  endif
endfunction

function! GenerateMakefile ()
  " first, make sure we're not overwriting an existing Makefile
  if filereadable( 'Makefile' ) && filewritable( 'Makefile' )
    if getfsize( 'Makefile' ) > 0
      echo "Makefile already exists in current directory."
      return
    endif
  else
    silent! exe "!touch Makefile" | redraw!
  endif
  " Attempt to figure out what platform we're running on.
  " Unfortunately, has( 'macunix' ) doesn't seem to work on OSX.
  if ( finddir( "Safari.app", "/Applications/" ) != "" )
    let s:openCmd = 'open'
    let s:browser = '/Applications/Safari.app'
  elseif has( 'win32' ) || has( 'win32unix' )
    " The browser path is wrong, but I haven't figured out a good
    " way to reliably know where IE is installed.
    let s:openCmd = 'start'
    let s:browser = 'C:\PROGRA~1\iexplore.exe'
  else
    echo "Can't figure out OS - Makefile aborted!"
    return
  endif
  " Create the Makefile
  let s:makefile = [
      \"OPENCMD = " . s:openCmd,
      \"BROWSER = " . s:browser,
      \"clean:",
      \"	cover -delete",
      \"test:",
      \"	prove t/",
      \"vtest:",
      \"	prove -v t/",
      \"shuffle:",
      \"	prove -s t/",
      \"cover:",
      \"	make clean",
      \"	PERL5OPT=-MDevel::Cover=-ignore,prove,+ignore,\\\\\.t  make test",
      \"	cover",
      \"	make report",
      \"report:",
      \"	$(OPENCMD) $(BROWSER) cover_db/coverage.html",
    \]
  " Write it to disk.
  let result = writefile( s:makefile, 'Makefile' )
  echo "Makefile written to current directory."
endfunction

nmap ,g :call GenerateTestStub()<cr>
nmap ,r :call RunTests()<cr>
nmap ,s :call SplitTestWindow()<cr>
nmap ,m :call GenerateMakefile()<cr>
nmap ,mt :!make test<cr>
nmap ,mv :!make vtest<cr>
nmap ,ms :!make shuffle<cr>
nmap ,mc :!make cover<cr>
nmap ,ml :!make clean<cr>
nmap ,mr :!make report<cr>

set errorformat=
    \%-G%.%#had\ compilation\ errors.,
    \%-G%.%#syntax\ OK,
    \%+Anot\ ok\%.%#-\ %m,
    \%C%.%#\(%f\ at\ line\ %l\),
    \%m\ at\ %f\ line\ %l.,
    \%+A%.%#\ at\ %f\ line\ %l\\,%.%#,
    \%+C%.%#
