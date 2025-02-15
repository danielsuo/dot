vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local google = function()
  return os.execute '[[ $OSTYPE == linux-gnu* ]] && command -v gcert' == 0
end

function workspace_name()
  local file_path = vim.api.nvim_buf_get_name(0)
  local ws = require("neocitc").workspace_from_path(file_path)
  if not ws then return "" end
  return "[" .. ws .. "]"
end

local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
function statusline_default()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local citc          = workspace_name()
  local git           = MiniStatusline.section_git({ trunc_width = 40 })
  local diff          = MiniStatusline.section_diff({ trunc_width = 75 })
  local diagnostics   = MiniStatusline.section_diagnostics({ trunc_width = 75, signs = signs })
  local lsp           = MiniStatusline.section_lsp({ trunc_width = 75 })
  local filename      = MiniStatusline.section_filename({ trunc_width = 140 })
  local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
  local location      = MiniStatusline.section_location({ trunc_width = 75 })
  local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

  return MiniStatusline.combine_groups({
    { hl = mode_hl,                  strings = { mode } },
    { hl = 'MiniStatuslineDevinfo',  strings = { git, diff, diagnostics, lsp } },
    '%<', -- Mark general truncate point
    { hl = 'MiniStatuslineFilename', strings = { citc, filename } },
    '%=', -- End left alignment
    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
    { hl = mode_hl,                  strings = { search, location } },
  })
end

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

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
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
    }
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
          vimgrep_arguments = {
            'rg',
            '--hidden',
          }
        },
        -- pickers = {}
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
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function() end
      })

      if vim.g.have_nerd_font then
        local diagnostic_signs = {}
        for type, icon in pairs(signs) do
          diagnostic_signs[vim.diagnostic.severity[type]] = icon
        end
        vim.diagnostic.config { signs = { text = diagnostic_signs } }
      end

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      local servers = { -- :help lspconfig-all
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-lspconfig').setup {
        ensure_installed = nil,
        automatic_installation = true,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    end,
  },

  { -- Autoformat
    'stevearc/conform.nvim',
    -- event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>ft',
        mode = '',
        desc = '[F]ile format',
      },
    },
    opts = {
      notify_on_error = false,
      formatters_by_ft = {
        lua = { 'stylua' },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
    config = function() -- :help cmp
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },

        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-u>'] = cmp.mapping.scroll_docs(-4),
          ['<C-d>'] = cmp.mapping.scroll_docs(4),
          ['<C-space>'] = cmp.mapping.confirm { select = true },
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'lazydev',
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
  { -- Theme
    'navarasu/onedark.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'onedark'
      vim.cmd.hi 'Comment gui=none'
    end,
    config = function()
      require('onedark').setup { style = 'darker' }
    end,
  },
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = true } },
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.files').setup()
      require('mini.pairs').setup()
      require('mini.bracketed').setup()
      require('mini.comment').setup()

      if google() then
        require('mini.statusline').setup({
          content = {
            active = statusline_default,
          }
        })
      end
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
      indent = { enable = true, disable = { 'ruby' } },
    },
  },
  {
    'smartpde/neoscopes',
    config = function()
      if not google() then
        local scopes = require('neoscopes')
        scopes.add_startup_scope()
      end
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
  { url = 'sso://user/vintharas/telescope-codesearch.nvim', enabled = google()},
  { url = 'sso://user/aktau/telescope-citc.nvim', enabled = google() },
  { url = 'sso://team/neovim-dev/neocitc', enabled = google() },
})

vim.g.have_nerd_font = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%C %s %l %r '
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
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
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

local telescope = require 'telescope.builtin'

local map = function(keys, func, desc, mode)
  mode = mode or 'n'
  if desc then
    vim.keymap.set(mode, keys, func, { desc = desc })
  else
    vim.keymap.set(mode, keys, func)
  end
end
local gmap = function(keys, func, desc, mode)
  if google() then
    map(keys, func, desc, mode)
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


