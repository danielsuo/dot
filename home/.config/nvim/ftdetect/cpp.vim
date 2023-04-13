au BufNewFile,BufRead *.cpp syn match cTodo "\<\(TODO\|FIXME\|QQ\|@@@\)"
au BufNewFile,BufRead *.cc syn match cTodo "\<\(TODO\|FIXME\|QQ\|@@@\)"
au BufNewFile,BufRead *.h syn match cTodo "\<\(TODO\|FIXME\|QQ\|@@@\)"
au BufNewFile,BufRead *.c syn match cTodo "\<\(TODO\|FIXME\|QQ\|@@@\)"
nmap go :FSHere<cr>
nmap goh :FSLeft<cr>
nmap gol :FSRight<cr>
