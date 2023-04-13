" Save
nmap <leader>s :w<cr>

" Save as
nmap <leader>a :sav<space>

" Open file if exists, create new otherwise
if !exists(":E")
  command -complete=file -nargs=1 E execute('silent! !mkdir -p "$(dirname "<args>")"') <Bar> e <args>
endif
nmap <leader>e :E<space>

" Redraw
nmap <leader>d :redraw!<cr>

" Update plugins
nmap <leader>` :so %<cr>:PlugInstall<cr>:UpdateRemotePlugins<cr>:q<cr>

" Quit
nmap <leader>q :q<cr>

" Kill buffer
nmap <leader>x :BD<cr>

" Toggle paste mode
set pastetoggle=<leader>v

" Navigation
nmap <leader>c :tabnew<CR>
nmap <leader>[ :tabprevious<CR>
nmap <leader>] :tabnext<CR>

" Splits
nmap <leader>; :vsp<CR>
nmap <leader>' :sp<CR>

" FZF
nmap <leader>F :History<CR>
nmap <leader>b :Buffers<CR>
nmap <leader>f :Files<cr>
nmap <leader>g :AFiles<CR>
nmap <leader>r :Rg<cr>
nmap <leader>R :ARg<cr>
nmap <leader>w :windows<cr>
nmap <leader>t :vimgreptasks<space>

" Mirror
nmap <leader>m :w<cr>:MirrorPush<cr>

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

" Navigating text
map <leader>/ <Plug>(incsearch-easymotion-/)
map <leader>? <Plug>(incsearch-easymotion-?)
map s <Plug>(easymotion-prefix)

" Global
nmap [; g;
nmap ]; g,
"xmap ga <Plug>(EasyAlign)
"nmap ga <Plug>(EasyAlign)

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> ga  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> ge  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> gc  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> gs  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> gw  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
"nnoremap <silent> gj  :<C-u>CocNext<CR>
" Do default action for previous item.
"nnoremap <silent> gk  :<C-u>CocPrev<CR>
" Resume latest coc list.
"nnoremap <silent> gp  :<C-u>CocListResume<CR>

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting
nmap gt :FormatCode<cr>
xmap gf  <Plug>(coc-format-selected)
nmap gf  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
"nmap <silent> <TAB> <Plug>(coc-range-select)
"xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}


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

" Window splitting defaults
set splitbelow
set splitright
