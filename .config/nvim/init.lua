vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }

-- [[ Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  desc = 'Auto update treesitter to load commands',
  callback = function()
    vim.cmd 'TSUpdate'
  end,
})

-- [[ Plugins ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

require('lazy').setup {
  { -- Default LSP configurations
    'neovim/nvim-lspconfig',
    config = function()
      vim.lsp.enable('lua_ls')
      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
              },
            },
            diagnostics = {
              globals = { 'vim', 'hs', 'spoon' }
            }
          }
        }
      })
      vim.lsp.enable('ruff')
      vim.lsp.enable('pylsp')
    end,
  },
  'tpope/vim-commentary', -- Easy comments.
  'rcarriga/nvim-notify',
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
    },
  },
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = {
            '%.orig$',
            '.git/*',
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
    end,
  },
  {
    'mfussenegger/nvim-lint',
  },
  {
    'klen/nvim-test',
    config = function()
      require('nvim-test').setup {
        term = 'toggleterm',
      }
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    cmd = { 'ConformInfo' },
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          cpp = { 'clang-format' },
          bzl = { 'buildifier' },
        },
      }
    end,
  },
  'nvim-lua/plenary.nvim',
  { 'nvim-tree/nvim-web-devicons', lazy = true },
  {
    'nvchad/ui',
    config = function()
      require 'nvchad'
      dofile(vim.g.base46_cache .. 'defaults')
      dofile(vim.g.base46_cache .. 'syntax')
      dofile(vim.g.base46_cache .. 'statusline')
      dofile(vim.g.base46_cache .. 'telescope')
    end,
  },
  {
    'nvchad/base46',
    lazy = true,
    build = function()
      require('base46').load_all_highlights()
    end,
  },
  'nvchad/volt', -- optional, needed for theme switcher
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = true } },
  {
    'goolord/alpha-nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      local startify = require 'alpha.themes.startify'
      -- available: devicons, mini, default is mini
      startify.file_icons.provider = 'devicons'
      require('alpha').setup(startify.config)
    end,
  },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.surround').setup()
      require('mini.files').setup()
      require('mini.pairs').setup()
      require('mini.bracketed').setup()
      require('mini.ai').setup()
      require('mini.comment').setup {
        mappings = {
          comment = 'g/',
          comment_line = 'g/',
          comment_visual = 'g/',
          textobject = 'g/',
        },
      }
      require('mini.trailspace').setup { event = { 'BufRead', 'BufNewFile' }, config = true }

      local map = require 'mini.map'
      map.setup = {
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diff(),
          map.gen_integration.gitsigns(),
          map.gen_integration.diagnostic(),
        },
        symbols = {
          encode = map.gen_encode_symbols.dot(),
        },
      }

    end,
  },
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'go',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'proto',
        'python',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = false },
    },
  },
  {
    'smartpde/neoscopes',
    config = function()
      local scopes = require 'neoscopes'
      scopes.add_startup_scope()
    end,
  },
  {
    'lcheylus/overlength.nvim',
    config = function()
      require('overlength').setup()
    end,
  },
  {
    'sontungexpt/url-open',
    branch = 'mini',
    event = 'VeryLazy',
    cmd = 'URLOpenUnderCursor',
    config = function()
      local status_ok, url_open = pcall(require, 'url-open')
      if not status_ok then
        return
      end
      url_open.setup {}
    end,
  },
  {
    'vim-scripts/vcscommand.vim',
    cmd = {
      'VCSAdd',
      'VCSAnnotate',
      'VCSBlame',
      'VCSCommit',
      'VCSDelete',
      'VCSDiff',
      'VCSGotoOriginal',
      'VCSInfo',
      'VCSLog',
      'VCSLock',
      'VCSRemove',
      'VCSRevert',
      'VCSReview',
      'VCSStatus',
      'VCSUpdate',
      'VCSUnlock',
      'VCSVimDiff',
    },
  },
  { 'mhinz/vim-signify' },
  {
    'folke/trouble.nvim',
    opts = {
      modes = {
        symbols = {
          win = {
            size = 0.3,
          },
          focus = true,
        },
        diagnostics = {
          focus = true,
        },
      },
    },
    cmd = 'Trouble',
  },
}

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%C %s %l %r '
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.colorcolumn = ''
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

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
local find_modified_files = function()
  require('telescope.builtin').git_status()
end
local toggle_mini_files = function()
  local MiniFiles = require 'mini.files'
  local _ = MiniFiles.close() or MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
  vim.defer_fn(function()
    MiniFiles.reveal_cwd()
  end, 30)
end

local dark = true
local toggle_light_dark = function()
  dark = not dark
  if dark then
    vim.cmd 'colorscheme tokyonight-night'
  else
    vim.cmd 'colorscheme tokyonight-day'
  end
end

local colorcolumn = false
local toggle_colorcolumn = function()
  colorcolumn = not colorcolumn
  if colorcolumn then
    vim.opt.colorcolumn = '80'
  else
    vim.opt.colorcolumn = ''
  end
end

-- [[ Normal Mode ]]
map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
map('gI', telescope.lsp_implementations, '[G]oto [I]mplementation')
map('gl', '<esc>:URLOpenUnderCursor<cr>', 'Open URL')
map('gr', telescope.lsp_references, '[G]oto [R]eferences')
map('gt', telescope.lsp_type_definitions, '[G]oto [T]ype definition')

map('<Esc>', '<cmd>nohlsearch<CR>', 'Clear highlights after search')
map('<C-h>', '<C-w><C-h>', 'Move focus to the left window')
map('<C-l>', '<C-w><C-l>', 'Move focus to the right window')
map('<C-j>', '<C-w><C-j>', 'Move focus to the lower window')
map('<C-k>', '<C-w><C-k>', 'Move focus to the upper window')
map('<C-S-h>', '<C-w><S-h>', 'Move focus to the left window')
map('<C-S-l>', '<C-w><S-l>', 'Move focus to the right window')
map('<C-S-j>', '<C-w><S-j>', 'Move focus to the lower window')
map('<C-S-k>', '<C-w><S-k>', 'Move focus to the upper window')
vim.keymap.set('i', '<C-a>', '<C-o>^')
vim.keymap.set('i', '<C-e>', '<C-o>$')
vim.keymap.set('n', '<C-a>', '0')
vim.keymap.set('n', '<C-e>', '$')
vim.keymap.set('v', '<C-a>', '0')
vim.keymap.set('v', '<C-e>', '$')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

map('<leader>d', '[D]iagnostics')

map('<leader>e', '[E]dit')
map('<leader>ew', ':e <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [W]indow')
map('<leader>eh', ':e ~/', '[E]dit from [H]ome dir')
map('<leader>es', ':sp <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [S]plit')
map('<leader>ev', ':vsp <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [V]ertical')
map('<leader>et', ':tabe <C-R>=expand("%:p:h") . "/" <CR>', '[E]dit in [T]ab')

map('<leader>f', '[F]ile')
map('<leader>fe', toggle_mini_files, '[F]ile [M]inifile')
map('<leader>fl', ':FormatLines<Enter>', '[F]ile [L]ine format')
map('<leader>fw', ':bp<bar>sp<bar>bn<bar>bd<CR>', '[File] buffer [C]lose')
map('<leader>fq', ':q<CR>', '[F]ile [Q]uit')
map('<leader>fs', ':w<CR>', '[F]ile [S]ave')
map('<leader>ft', format_file, '[F]ile forma[T]')
map('<leader>fx', ':Ex<CR>', '[F]ile E[X]')

map('<leader>h', '[H]git')

map('<leader>l', '[L]SP')
map('<leader>la', vim.lsp.buf.code_action, '[L]SP code [A]ction', { 'n', 'x' })
map('<leader>lr', vim.lsp.buf.rename, '[L]SP [R]ename')

map('<leader>n', 'Sessio[N]s')
map('<leader>nw', ':lua require("mini.sessions").write()<CR>', 'Sessio[N]s [W]rite')

map('<leader>q', vim.diagnostic.setloclist, '[Q]uickfix list')

map('<leader>s', '[S]earch')
map('<leader>sb', telescope.buffers, '[S]earch [B]uffers')
map('<leader>sd', telescope.diagnostics, '[S]earch [D]iagnostics')
map(
  '<leader>sf',
  ':lua require("telescope.builtin").find_files{ hidden = true, search_dirs = require("neoscopes").get_current_paths() }<CR>',
  '[S]earch [F]iles'
)
map('<leader>sg', ':lua require("telescope.builtin").live_grep{ hidden = true, search_dirs = require("neoscopes").get_current_paths() }<CR>', '[S]earch [G]rep')
map('<leader>sh', telescope.help_tags, '[S]earch [H]elp')
map('<leader>sk', telescope.keymaps, '[S]earch [K]eymaps')
map('<leader>sm', find_modified_files, '[S]earch [M]odified files')
map('<leader>sn', find_neovim_files, '[S]earch [N]eovim files')
map('<leader>sp', ':lua require("neoscopes").select()<CR>', '[S]earch neosco[P]s')
map('<leader>sr', telescope.resume, '[S]earch [R]esume')
map('<leader>ss', telescope.lsp_document_symbols, '[S]earch document [s]ymbols')
map('<leader>sS', telescope.lsp_dynamic_workspace_symbols, '[S]earch workspace [S]ymbols')
map('<leader>st', telescope.builtin, '[S]earch [T]elescope pickers')
map('<leader>sv', ':Telescope commands<CR>', '[S]earch [V]im commands')
map(
  '<leader>sW',
  ':lua require("telescope.builtin").grep_string{ hidden = true, search_dirs = require("neoscopes").get_current_paths() }<CR>',
  '[S]earch [W]ord'
)
map('<leader>sz', find_fuzzy_in_current, '[S]earch fu[Z]zy in current')
map('<leader>s.', telescope.oldfiles, '[S]earch recent files')
map('<leader>s/', live_grep_in_open, '[S]earch in open files')

map('<leader>t', '[T]rouble')
map('<leader>ts', ':Trouble symbols toggle<CR>', '[T]rouble [S]ymbols')
map('<leader>td', ':Trouble diagnostics toggle<CR>', '[T]rouble [D]iagnostics')

map('<leader>u', '[U]I')
map('<leader>ut', toggle_light_dark, '[U]I [T]oggle light/dark')
map('<leader>uc', toggle_colorcolumn, '[U]I toggle [C]olor column')

map('<leader>w', '[W]orkspace')

map('<leader>z', ':Lazy<Enter>', 'La[Z]y')

-- [[ Terminal mode ]]
map('<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode', 't')

