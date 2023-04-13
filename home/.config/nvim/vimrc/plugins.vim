call plug#begin('~/.local/share/nvim/plugged')

" Theme
Plug 'joshdick/onedark.vim'

" Airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'enricobacis/vim-airline-clock'
let g:airline_theme='onedark'
set laststatus=2

" Git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify' " Gutter
Plug 'junegunn/gv.vim'

" Autoload
Plug 'tmux-plugins/vim-tmux-focus-events'

" Text
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'          " al / il
Plug 'beloglazov/vim-textobj-quotes'  " aq / iq
Plug 'jceb/vim-textobj-uri'           " au / iu / go
Plug 'sgur/vim-textobj-parameter'     " a / i
Plug 'adriaanzon/vim-textobj-matchit' " am / im
Plug 'thinca/vim-textobj-between'     " af{char} / if{char}
Plug 'whatyouhide/vim-textobj-xmlattr' " ax / ix

Plug 'jiangmiao/auto-pairs'
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutBackInsert = ''
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'

Plug 'tpope/vim-rsi'

Plug 'easymotion/vim-easymotion'

Plug 'haya14busa/vim-easyoperator-line'
Plug 'haya14busa/vim-easyoperator-phrase'
Plug 'terryma/vim-multiple-cursors'
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_start_key='<leader>n'
let g:multi_cursor_next_key='<C-j>'
let g:multi_cursor_prev_key='<C-k>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'haya14busa/incsearch.vim'

Plug 'tpope/vim-repeat'
silent! call repeat#set("\<Plug>vim-surround", v:count)
silent! call repeat#set("\<Plug>vim-unimpaired", v:count)

Plug 'junegunn/vim-easy-align'

" File navigation
Plug 'danielsuo/vim-fswitch'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
command! -bang -nargs=* Rg
      \ call fzf#vim#grep(
      \ 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \ <bang>0 ? fzf#vim#with_preview('up:60%')
      \ : fzf#vim#with_preview('right:50%:hidden', '?'),
      \ <bang>0)

command! -bang -nargs=* ARg
      \ call fzf#vim#grep(
      \ 'rg --no-ignore --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
      \ <bang>0 ? fzf#vim#with_preview('up:60%')
      \ : fzf#vim#with_preview('right:50%:hidden', '?'),
      \ <bang>0)

command! -bang -nargs=? -complete=dir AFiles
      \ call fzf#vim#files(
      \ <q-args>, {'source': 'rg --no-ignore --files --hidden'},
      \ <bang>0)

Plug 'vim-scripts/ingo-library'
Plug 'vim-scripts/GrepCommands'
Plug 'vim-scripts/GrepHere'
Plug 'vim-scripts/GrepTasks'

" Buffers, panes, windows
Plug 'qpkorr/vim-bufkill'

" IDE
Plug 'sheerun/vim-polyglot'
Plug 'kien/rainbow_parentheses.vim'
Plug 'jceb/vim-hier'
Plug 'zenbro/mirror.vim'

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" NERDCommenter
Plug 'scrooloose/nerdcommenter'

" QuickFix
Plug 'milkypostman/vim-togglelist'
let g:toggle_list_no_mappings = 1

" File tree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeShowHidden=1

" Debugging
" Plug 'Shougo/vimproc.vim', {'do' : 'make'}
" Plug 'idanarye/vim-vebugger'

" Code formatting
" Automatically format on save
Plug 'Chiel92/vim-autoformat'
" nmap <leader>t :Autoformat<cr>
" if !exists('g:formatdef_clangformat')
"   let s:configfile_def = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" -style=file'"
"   let s:noconfigfile_def = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" -style=google'"
"   let g:formatdef_clangformat = "g:ClangFormatConfigFileExists() ? (" . s:configfile_def . ") : (" . s:noconfigfile_def . ")"
" endif

Plug 'SirVer/ultisnips', {'for': ['python']}

let g:coc_global_extensions = [
\   'coc-css',
\   'coc-rls',
\   'coc-html',
\   'coc-json',
\   'coc-python',
\   'coc-yaml',
\   'coc-emmet',
\   'coc-emoji',
\   'coc-vetur',
\   'coc-eslint',
\   'coc-prettier',
\   'coc-tsserver',
\   'coc-ultisnips'
\ ]

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if has('patch8.1.1068')
  " Use `complete_info` if your (Neo)Vim version supports it.
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

call plug#end()
