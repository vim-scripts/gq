" File: gq.vim
" Last Change: 2003 Nov 19
" Maintainer: Klaus Bosau <kbosau@web.de>
" Version: 0.9

if exists("loaded_gq")
  finish
endif

let loaded_gq = 1
let s:cpo = &cpo | set cpo&vim

fun GQ(...) range
  fun! s:Save(opts)
    fun! s:Val(opt)
      exe 'let s = &l:' . a:opt | return escape(s, '"')
    endfun
    return "let rest = '" . substitute(a:opts, '\S\+', '\="let &l:" . submatch(0) . "=\"" . s:Val(submatch(0)) . "\" |"', 'g') . "'"
  endfun

  fun! s:Fmt() range
    exe a:lastline . ' put _' | ma y
    exe a:firstline
    while line('.') < line("'y")
      let q = matchstr(getline('.'), '^.\{-}>>\@!')
      let l = strlen(q)
      exe 'norm! 0' . "\<C-V>" . '-/\v^( *\u{,5}\>+)@>.*%(\n\1@!|\n\1\>|%$)/' . 
		\"\<Cr>" . l . "|r gq']0m'\<C-V>'[" . l . '|c' . q . "\<Esc>''+"
    endwhile
    'y- s/\n//
  endfun

  exe s:Save('et km sel fo ai com tw')
  exe 'setl et km= sel=inclusive ' . (a:0 > 0 ? a:1 : '')
  if &l:com =~ 'n:>' && &l:fo =~ 'c'
    exe 'sil ' . a:lastline . ' put _' | ma x
    exe a:firstline . ",'x-" . ' s/\v^( *)(%(\> *)+)(\u{1,5})%( *\>)@=/\1\3\2/e'
    exe a:firstline . ",'x-" . ' s/\v%(^ *\S@=\u{,5}[> ]*)@<=%( {1,2})\>@=//ge'
    exe a:firstline . ",'x-" . ' s/\v%(^\1\>+.*\S.*)@<=\n( *\u{,5} *\>*) {,2}%(%(\w+\W{,2}){1,3}$)@=/ /ce'
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

vn <silent> q :call GQ()<Cr>
" Acts according to settings ('fo', 'ai', 'com', 'tw') made earlier. Use
" ":setl" (see ":h :setl") to customize!
"
"vn <silent> q :call GQ('fo=tcqn ai com=n:>,fb:-,fb:*,b:\\| tw=70')<Cr>
" Uncomment this instead if you want it to act independent of global/local
" settings. (It's preset for mail message files, i. e. it wraps lines at 70
" characters per line, preserves lists both numbered and subdivided via
" list-bullets '-' and '*' and foreign quotes prepended by '|'.) Settings made
" earlier are not affected since values passed as arguments are assigned
" temporarily only. You may use this method to declare several shortcuts for
" differing tasks as well.

let &cpo = s:cpo

" vim600:nowrap:
