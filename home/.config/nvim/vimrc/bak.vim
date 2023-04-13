""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:
"   Daniel Suo
"   dsuo@post.harvard.edu
"
" Version:
"   0.1
"
" Sections:
"   -> General
"   -> Plugs
"   -> VIM user interface
"   -> Colors and Fonts
"   -> Files, backups, and undo
"   -> Text, tab, and indent
"   -> Edit mappings
"   -> On-save actions
"   -> Helper functions
"   -> Programming
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Force Vim to source .vimrc file if present in working directory
set exrc

" Make sure working directory .vimrc files don't do crazy things
set secure

" Set to auto read when a file is changed from the outside
set autoread

" Auto change working directory to file currently open
" set autochdir

" Detect filetype, load associated plugin, and associated indent file
filetype on
filetype plugin on
filetype indent on
set omnifunc=syntaxcomplete#Complete

" Folding
set foldmethod=syntax
set foldlevelstart=99

" Map leader
map <space> <leader>

nmap <leader>s :w<cr>
nmap <leader>a :sav<space>

if !exists(":E")
  command -complete=file -nargs=1 E execute('silent! !mkdir -p "$(dirname "<args>")"') <Bar> e <args>
endif
nmap <leader>e :E<space>

nmap <leader>d :redraw!<cr>
nmap <leader>` :so %<cr>:PlugInstall<cr>:UpdateRemotePlugins<cr>:q<cr>
nmap <leader>q :q<cr>
nmap <leader>x :BD<cr>
nmap <leader>b :b<space>
set pastetoggle=<leader>v

" Set long history
set history=1000

" Clipboard
" set clipboard=unnamed,unnamedplus

" Enable mouse
set mouse=a

" Change cursor depending on mode (for tmux and iTerm2 on macOS only)
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif
:autocmd InsertEnter * set cul
:autocmd InsertLeave * set nocul

" Command line
cabbr <expr> %% expand('%:p:h')

"Get diff with saved
function! s:DiffGitWithSaved()
  let filename = expand('%')
  let diffname = tempname()
  execute 'silent w! '.diffname
  execute '!git diff --color=always --no-index -- '.shellescape(filename).' '.diffname
endfunction
com! DiffGitSaved call s:DiffGitWithSaved()
nmap <leader>gds :DiffGitSaved<CR>



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins to check out
" - https://github.com/tenfyzhong/CompleteParameter.vim
" - https://github.com/SirVer/ultisnips

call plug#begin('~/.local/share/nvim/plugged')

" Manage statusline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" let g:airline_theme='solarized'
let g:airline_theme='onedark'
set laststatus=2

" Enable the list of buffers
" let g:airline#extensions#tabline#enabled = 1
" let g:airline#extensions#tabline#show_buffers = 1
" let g:airline#extensions#tabline#show_tabs = 1

" Show just the filename
" let g:airline#extensions#tabline#fnamemod = ':t'

" Rename tabs
" let g:airline#extensions#taboo#enabled = 1

" Tablines
Plug 'mkitt/tabline.vim'

" Rename tabs
Plug 'gcmt/taboo.vim'
" let g:taboo_tabline = 0

" Color schemes
Plug 'altercation/vim-colors-solarized'
Plug 'flazz/vim-colorschemes'
Plug 'ajmwagar/vim-deus'
Plug 'fneu/breezy'
Plug 'joshdick/onedark.vim'
" if (empty($TMUX))
  " if (has("nvim"))
    " let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  " endif
  " if (has("termguicolors"))
    " set termguicolors
  " endif
" endif

" Local vimrc
Plug 'MarcWeber/vim-addon-local-vimrc'
let g:local_vimrc = {'names':['.vimrc', '.exrc'],'hash_fun':'LVRHashOfFile'}

" Git gutter
Plug 'mhinz/vim-signify'

" Autoload
Plug 'tmux-plugins/vim-tmux-focus-events'

" Syntastic
Plug 'vim-syntastic/syntastic'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1

let g:syntastic_c_clang_tidy_post_args = ""
let g:syntastic_go_checkers = ['govet', 'errcheck', 'go']
augroup filetype_sbt
  autocmd!
  autocmd BufNewFile,BufRead *.sbt set filetype=sbt
  autocmd FileType sbt setlocal syntax=scala
augroup END
let g:syntastic_ignore_files = ['\m\c\.h$', '\m\.sbt$']
map <leader>gs :SyntasticToggleMode<cr>

" Code completer
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
" let g:ycm_global_ycm_extra_conf = '~/dotfiles/unix/apps/.ycm_extra_conf.py'
" let g:ycm_collect_identifiers_from_tags_files = 1

" nnoremap <Leader>gt :YcmCompleter GoTo<CR>
" nnoremap <Leader>gtt :YcmCompleter GetType<CR>

" if has('macunix')
" let g:clang_library_path='/usr/local/opt/llvm/lib'
" elseif has('unix')
" endif
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
" autocmd FileType scala let b:deoplete_disable_auto_complete = 1
let g:deoplete#omni#input_patterns = {}
let g:deoplete#omni#input_patterns.scala = '[^. *\t]\.\w*'

Plug 'zchee/deoplete-clang'
Plug 'zchee/deoplete-jedi'
Plug 'Shougo/neco-vim'
Plug 'zchee/deoplete-zsh'

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

let g:LanguageClient_serverCommands = { 'cpp': ['yourCQueryDirectory/build/release/bin/cquery', '--log-file=/tmp/cq.log'] }
let g:LanguageClient_loadSettings = 1

Plug 'wellle/tmux-complete.vim'
let g:tmuxcomplete#trigger = ''
Plug 'tmux-plugins/vim-tmux'

if has('macunix')
  Plug 'thalesmello/webcomplete.vim'
  set completefunc=webcomplete#complete
endif

" Plug 'autozimu/LanguageClient-neovim'

" Automatically regenerate ctags
Plug 'craigemery/vim-autotag'

" Rtags
" Plug 'lyuts/vim-rtags'

" Automatically format on save
Plug 'Chiel92/vim-autoformat'
nmap <leader>cr :Autoformat<cr>
if !exists('g:formatdef_clangformat')
  let s:configfile_def = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" -style=file'"
  let s:noconfigfile_def = "'clang-format -lines='.a:firstline.':'.a:lastline.' --assume-filename=\"'.expand('%:p').'\" -style=google'"
  let g:formatdef_clangformat = "g:ClangFormatConfigFileExists() ? (" . s:configfile_def . ") : (" . s:noconfigfile_def . ")"
endif

" Navigating header / source files
Plug 'derekwyatt/vim-fswitch'
autocmd FileType cpp nmap <Leader>go :FSHere<cr>
autocmd FileType c nmap <Leader>go :FSHere<cr>

" Fuzzy finding
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
nmap <Leader>f :Files<cr>
autocmd FileType cpp nmap <Leader>t :Tags<cr>
nmap <Leader>w :Windows<cr>

" Git
Plug 'tpope/vim-fugitive'

" Sessions
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'

" Text objects
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-line'          " al / il
Plug 'beloglazov/vim-textobj-quotes'  " aq / iq
Plug 'jecb/vim-textobj-uri'           " au / iu / go
Plug 'sgur/vim-textobj-parameter'     " a / i
Plug 'adriaanzon/vim-textobj-matchit' " am / im
Plug 'thinca/vim-textobj-between'     " af{char} / if{char}
Plug 'whatyouhide/vim-textobj-xmlattr' " ax / ix

" NERDCommenter
Plug 'scrooloose/nerdcommenter'

" File tree
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeShowHidden=1
map <leader>gf :NERDTreeToggle<cr>

" Auto pair matching
let g:NERDSpaceDelims = 1
Plug 'jiangmiao/auto-pairs'
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutBackInsert = ''

" Commands that come in pairs
Plug 'tpope/vim-unimpaired'
nmap [; g;
nmap ]; g,

" Keyboard
Plug 'tpope/vim-rsi'

" Easymotion
Plug 'easymotion/vim-easymotion'
map <leader>m <Plug>(easymotion-prefix)
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
map <leader>/ <Plug>(incsearch-easymotion-/)
map <leader>? <Plug>(incsearch-easymotion-?)

" Surround text with other stuff
Plug 'tpope/vim-surround'

" Buffer kill
Plug 'qpkorr/vim-bufkill'

" Repeat
Plug 'tpope/vim-repeat'
silent! call repeat#set("\<Plug>vim-surround", v:count)
silent! call repeat#set("\<Plug>vim-unimpaired", v:count)

" Alignment
Plug 'junegunn/vim-easy-align'
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)"

" Syntax highlighting
Plug 'ekalinin/Dockerfile.vim'
Plug 'dcharbon/vim-flatbuffers'
Plug 'PProvost/vim-markdown-jekyll'
Plug 'tpope/vim-markdown'

" TODO: Refactor these into filetype mappings
" Javascript
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

" Python
if has('python')
  Plug 'tpict/vim-virtualenv'

  let python_version = get(matchlist(system('python --version'), '\d'), 0, '2')
  let python_executable = systemlist('which python')[0]
  let python3_executable = systemlist('which python3')[0]
  let g:python_host_prog = python_executable
  let g:python3_host_prog = python3_executable

  if python_version <= 2
    Plug 'python-rope/ropevim'
    autocmd FileType python nmap <leader>gt :RopeGotoDefinition<cr>
    autocmd FileType python nmap <leader>gd :RopeShowDoc<cr>
    let g:ropevim_goto_def_newwin = 'vnew'
  endif

  autocmd FileType python,pyrex setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab nosmartindent

  let g:syntastic_python_checkers = ['flake8', 'pylint', 'pyflakes']
  Plug 'bps/vim-textobj-python'
  Plug 'heavenshell/vim-pydocstring'
  Plug 'ivanov/vim-ipython'
  let g:ipy_perform_mappings = 0

  map <C-Return> :python run_this_file()<cr>
  map <leader>r :python run_this_line()<cr>j
  map <M-r> :python dedent_run_this_line()<cr>j
  xmap <leader>r :python run_these_lines()<cr>
  xmap <M-r> :python dedent_run_these_lines()<cr>

endif

if has('python3')
  Plug 'roxma/nvim-yarp'
endif

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" Matlab
Plug 'daeyun/vim-matlab'
Plug 'lazywei/vim-matlab'

" Scala
" Plug 'ensime/ensime-vim'
" autocmd BufWritePost *.scala silent :EnTypeCheck
Plug 'derekwyatt/vim-scala'
Plug 'dansomething/vim-eclim'
let g:EclimCompletionMethod = 'omnifunc'
let g:EclimFileTypeValidate = 0
autocmd FileType scala nmap <leader>gt :ScalaSearch<cr>

" IDE
Plug 'kien/rainbow_parentheses.vim'
Plug 'jceb/vim-hier'

call plug#end()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Display line numbers
set number relativenumber

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Unsets the last search pattern register by hitting return
nnoremap <silent> <Esc><Esc> <Esc>:nohlsearch<CR><Esc>

" Don't redraw while executing macros (good performance config)
set lazyredraw

" For regular expressions turn magic on
set magic

" Show matching brackets when text indicator is over them
set showmatch

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Navigation
nmap <leader>c :tabnew<CR>
nmap <leader>[ :tabprevious<CR>
nmap <leader>] :tabnext<CR>

" Splits
nmap <leader>; :vsp<CR>
nmap <leader>' :sp<CR>

" Window splitting defaults
set splitbelow
set splitright

" Navigating splits
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l
nmap <leader>o <C-w>w

" Moving windows
nmap <leader>H <C-w>H
nmap <leader>J <C-w>J
nmap <leader>K <C-w>K
nmap <leader>L <C-w>L

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax on

" Set terminal gui colors
set termguicolors

" Set color scheme to solarized
" colorscheme solarized
colorscheme onedark


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Edit mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character
map 0 ^
nmap <C-e> $
nmap <C-a> 0

" Move lines
nnoremap <C-n> :m .+1<CR>==
nnoremap <C-p> :m .-2<CR>==
" inoremap <C-n> <Esc>:m .+1<CR>==gi
" inoremap <C-p> <Esc>:m .-2<CR>==gi
vnoremap <C-n> :m '>+1<CR>gv=gv
vnoremap <C-p> :m '<-2<CR>gv=gv

" Move in insert mode
inoremap <C-n> <Down>
inoremap <C-p> <Up>

" Yank region without moving cursor
:vmap y ygv<Esc>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => On-save actions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Delete trailing white space on save, useful for Python and CoffeeScript ;)
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()
autocmd BufWrite *.coffee :call DeleteTrailingWS()


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  endif
  return ''
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Programming
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set tag files to look at
set tags+=./tags,tags;$HOME
