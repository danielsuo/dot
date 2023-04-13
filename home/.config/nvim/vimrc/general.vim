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

" Turn off backup
set nobackup
set nowb
set noswapfile

" Folding
set foldmethod=syntax
set foldlevelstart=99

" Map leader
map <space> <leader>

" Set long history
set history=1000

" Set hidden for editing multiple buffers
set hidden

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

" Display line numbers
set number

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
