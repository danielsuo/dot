""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:
"   Daniel Suo
"   dsuo@post.harvard.edu
"
" Version: 0.2
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set exrc
set secure

" Current directory
let s:cwd = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Sourcing function
function! s:src(section)
  exec "source " . s:cwd . "/vimrc/" . a:section . ".vim"
endfunction

call s:src("general")
call s:src("plugins")
call s:src("bindings")
call s:src("formatting")
call s:src("theme")

augroup filetypedetect
  au BufRead,BufNewFile *.bpred setfiletype cpp
augroup END
augroup filetypedetect
  au BufRead,BufNewFile *.l1d_pref setfiletype cpp
augroup END
augroup filetypedetect
  au BufRead,BufNewFile *.l2c_pref setfiletype cpp
augroup END
augroup filetypedetect
  au BufRead,BufNewFile *.llc_repl setfiletype cpp
augroup END

if $GOOGLE_HOME
  source /usr/share/vim/google/google.vim
endif

set shiftwidth=2
