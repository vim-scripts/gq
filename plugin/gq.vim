" File: gq.vim
" Last Change: 2004 April 20
" Maintainer: Klaus Bosau <kbosau@web.de>
" Version: 0.91

if exists("loaded_gq")
  finish
endif

let loaded_gq = 1
let s:cpo = &cpo | set cpo&vim

fun! s:Requote(...) range
  exe a:lastline . ' put _' | ma z
  exe a:firstline . ",'z-" . ' s/\v^( *)(%(\> *)+)(\u{1,5})%( *\>)@=/\1\3\2/e'
  exe a:firstline . ",'z-" . ' s/\v%(^ *\S@=\u{,5}[> ]*)@<=%( {1,2})\>@=//ge'
  exe 'sil! ' . a:firstline . ",'z-" . ' g/\v(^ *\u{,5}\>+ *)%(\n\1$)@=/d _'
  exe a:firstline . ",'z-" . ' s/\v%(^\1\>+.*\S.*)@<=\n( *\u{,5} *\>*) {,2}%(%(\w+\W{,2}){1,3}$)@=/ /ce'
  'z- s/\n//
  if a:0 > 0 | let b:requoted = 1 | endif
endfun

fun! GQ(...) range

  fun! s:Save(opts)
    fun! s:Val(opt)
      exe 'let s = &l:' . a:opt | return escape(s, '"')
    endfun
    return "let rest = '" . substitute(a:opts, '\S\+', '\="let &l:" . submatch(0) . "=\"" . s:Val(submatch(0)) . "\" |"', 'g') . "'"
  endfun

  fun! s:Fmt() range
    exe s:Save('et ai')
    setl et ai
    exe a:lastline . ' put _' | ma y
    exe a:firstline
    while line('.') < line("'y")
      let q = matchstr(getline('.'), '^.\{-}>>\@!')
      let l = strlen(q)
      exe 'norm! 0' . "\<C-V>" . '-/\v^( *\u{,5}\>+)@>.*%(\n\1@!|\n\1\>|%$)/' . 
		\"\<Cr>" . l . "|r gq']0m'\<C-V>'[" . l . '|c' . q . "\<Esc>''+"
    endwhile
    'y- s/\n//
    exe rest
  endfun

  exe s:Save('km sel fo ai com tw')
  exe 'setl km= sel=inclusive ' . (a:0 > 0 ? a:1 : '')
  if &l:com =~ 'n:>' && &l:fo =~ 'c'
    exe 'sil ' . a:lastline . ' put _' | ma x
    if !exists('b:requoted')
      exe a:firstline . ",'x-" . ' call s:Requote()'
    endif
    exe 'sil ' . a:firstline . ' put! _' | +
    while line('.') < line("'x")
      if getline('.') =~ '\v^ *\u{,5} *\>'
        sil! .;-/\v^ *\u{,5} *\>.*%(\n%( *\u{,5} *\>)@!|%$)/ call s:Fmt()
      else
        exe 'sil norm! V-/\v\n *\u{,5} *\>|%' . (line("'x") - 1) . "l/\<Cr>gq"
      endif
      +
    endwhile
    exe 'sil ' . a:firstline . ' d _'
    sil 'x- s/\n//
  else
    exe a:firstline . 'norm! V' . (a:lastline - a:firstline + 1) . '_gq'
  endif
  exe rest
endfun

nn <silent> <unique> ,r :% call <SID>Requote('all')<Cr>
" Fixes up bad quoting markup.

com! Requote :% call <SID>Requote('all')
" Like above. Use this to fix up bad quoting automatically on start-up.
" ("vim +Requote <file>" (see ":h -c"))

vn <silent> <unique> q :call GQ()<Cr>
" Acts according to settings ('fo', 'ai', 'com', 'tw') made earlier. Use
" ":setl" (see ":h :setl") to customize!

"vn <silent> <unique> q :call GQ('fo=tcqn ai com=n:>,fb:-,fb:*,b:\\| tw=70')<Cr>
" Uncomment this instead if you want "q" to act independent of global/local
" settings. (By default it's preset for mail message files, i. e. it wraps
" lines at 70 characters per line, preserves lists both numbered and
" subdivided via list-bullets '-' and '*' and also foreign quotes prepended by
" '|'.) Settings made earlier are not affected. You may use this method to
" declare several shortcuts for differing tasks as well.

let &cpo = s:cpo

" vim600:fo=crq12:com=n\:\":nojs:so=5:siso=10:nowrap:inde=:sts=2:sm:
