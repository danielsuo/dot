local telescope = require 'telescope.builtin'

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  if desc then
    vim.keymap.set(mode, keys, func, { desc = desc })
  else
    vim.keymap.set(mode, keys, func)
  end
end

local find_neovim_files = function()
  telescope.find_files { cwd = vim.fn.stdpath 'config' }
end
local find_fuzzy_in_current = function()
  telescope.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end
local live_grep_in_open = function()
  telescope.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end
local format_file = function()
  require('conform').format { async = true, lsp_format = 'fallback' }
end

-- [[ Normal Mode ]]
map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
map('gl', '<esc>:URLOpenUnderCursor<cr>', 'Open URL')
map('gr', telescope.lsp_references, '[G]oto [R]eferences')
map('gt', telescope.lsp_type_definitions, '[G]oto [T]ype definition')
-- map('g[', )

-- Rename the variable under your cursor.
--  Most Language Servers support renaming across files, etc.
map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

-- Execute a code action, usually your cursor needs to be on top of an error
-- or a suggestion from your LSP for this to activate.
map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

map('<Esc>', '<cmd>nohlsearch<CR>', 'Clear highlights after search')
map('<C-h>', '<C-w><C-h>', 'Move focus to the left window')
map('<C-l>', '<C-w><C-l>', 'Move focus to the right window')
map('<C-j>', '<C-w><C-j>', 'Move focus to the lower window')
map('<C-k>', '<C-w><C-k>', 'Move focus to the upper window')
map('<C-;>', '<C-w><C-v>', 'Split window vertically')

map('<leader>c', '[C]ode')
map('<leader>e', '[E]dit')
map('<leader>ew', ':e <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [W]indow')
map('<leader>es', ':sp <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [S]plit')
map('<leader>ev', ':vsp <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [V]ertical')
map('<leader>et', ':tabe <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [T]ab')
map('<leader>d', '[D]ocument')
map('<leader>ds', telescope.lsp_document_symbols, '[D]ocument [S]ymbols')
map('<leader>f', '[F]ile')
map('<leader>fe', ':lua MiniFiles.open()<CR>', '[F]ile [M]inifile')
map('<leader>fl', ':FormatLines<Enter>', '[F]ile [L]ine format')
map('<leader>fs', ':w<CR>', '[F]ile [S]ave')
map('<leader>ft', format_file, '[F]ile forma[T]')
map('<leader>fq', ':q<CR>', '[F]ile [Q]uit')
map('<leader>fx', ':Ex<CR>', '[F]ile E[X]')
map('<leader>l', ':Lazy<Enter>', '[L]azy')
map('<leader>q', vim.diagnostic.setloclist, '[Q]uickfix list')
map('<leader>r', '[R]ename')
map('<leader>s', '[S]earch')
map('<leader>sb', telescope.buffers, '[S]earch [B]uffers')
map('<leader>sd', telescope.diagnostics, '[S]earch [D]iagnostics')
map('<leader>sf', telescope.find_files, '[S]earch [F]iles')
map('<leader>sg', telescope.live_grep, '[S]earch live [G]rep')
map('<leader>sh', telescope.help_tags, '[S]earch [H]elp')
map('<leader>sk', telescope.keymaps, '[S]earch [K]eymaps')
map('<leader>sn', find_neovim_files, '[S]earch [N]eovim files')
map('<leader>sp', ':lua require("neoscopes").select()<CR>', '[S]earch neosco[P]s')
map('<leader>sr', telescope.resume, '[S]earch [R]esume')
map('<leader>st', telescope.builtin, '[S]earch [T]elescope pickers')
map('<leader>sw', telescope.grep_string, '[S]earch [W]ord')
map('<leader>sz', find_fuzzy_in_current, '[S]earch fu[Z]zy in current')
map('<leader>s.', telescope.oldfiles, '[S]earch recent files')
map('<leader>s/', live_grep_in_open, '[S]earch in open files')
map('<leader>t', '[T]oggle')
map('<leader>w', '[W]orkspace')
map('<leader>ws', telescope.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

-- [[ Terminal mode ]]
map('<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode', 't')


