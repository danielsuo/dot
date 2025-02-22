vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.base46_cache = vim.fn.stdpath 'data' .. '/base46_cache/'
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

local google = os.execute '[[ $OSTYPE == linux-gnu* ]] && command -v gcert > /dev/null' == 0

local workspace_name = function()
  local file_path = vim.api.nvim_buf_get_name(0)
  local ws = require('neocitc').workspace_from_path(file_path)
  if not ws then
    return ''
  end
  return '[' .. ws .. ']'
end

local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
local statusline_default = function()
  local mode, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
  local citc = workspace_name()
  local git = MiniStatusline.section_git { trunc_width = 40 }
  local diff = MiniStatusline.section_diff { trunc_width = 75 }
  local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75, signs = signs }
  local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
  local filename = MiniStatusline.section_filename { trunc_width = 140 }
  local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
  local location = MiniStatusline.section_location { trunc_width = 75 }
  local search = MiniStatusline.section_searchcount { trunc_width = 75 }

  return MiniStatusline.combine_groups {
    { hl = mode_hl, strings = { mode } },
    { hl = 'MiniStatuslineDevinfo', strings = { git, diff, diagnostics, lsp } },
    '%<', -- Mark general truncate point
    { hl = 'MiniStatuslineFilename', strings = { citc, filename } },
    '%=', -- End left alignment
    { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
    { hl = mode_hl, strings = { search, location } },
  }
end

local gplug = function(spec)
  spec.enabled = google
  return spec
end
local gdir = function(spec)
  spec.enabled = google
  spec.dir = '/usr/share/vim/google/' .. spec.dir
  if not spec.dependencies then
    spec.dependencies = { 'maktaba' }
  else
    table.insert(spec.dependencies, 'maktaba')
  end
  return spec
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

require('lazy').setup {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'rcarriga/nvim-notify',
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup {}
    end,
  },
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
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup {}
    end,
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
          path_display = function(_, path)
            path = path:gsub('^/google/src/cloud/[^/]+/[^/]+/google3/', 'google3/', 1)
            path = path:gsub('^google3/java/com/google/', 'g3/j/c/g/', 1)
            path = path:gsub('^google3/javatests/com/google/', 'g3/jt/c/g/', 1)
            path = path:gsub('^google3/third_party/', 'g3/3rdp/', 1)
            path = path:gsub('^google3/', 'g3/', 1)
            return path
          end,
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
    'mfussenegger/nvim-lint',
  },
  {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'pylsp',
        },
      }
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'hrsh7th/cmp-nvim-lsp',
    },
    opts = function(_, opts)
      local ciderlsp_config = {
        cmd = {
          '/google/bin/releases/cider/ciderlsp/ciderlsp',
          '--tooltag=neovim-lsp',
          '--noforward_sync_responses',
        },
        filetypes = {
          'c',
          'cpp',
          'objc',
          'objcpp',
          'java',
          'kotlin',
          'go',
          'python',
          'typescript',
          'typescriptreact',
          'proto',
          'textproto',
          'dart',
          'bzl',
          'cs',
          'googlesql',
          'eml',
          'mlir',
          'dataz',
          'soy',
          'graphql',
          'javascript',
          'javascriptreact',
          'css',
          'scss',
          'html',
          'json',
          'jslayout',
          'gcl',
          'borg',
          'markdown',
          'piccolo',
          'ncl',
          'conf',
        },
        root_dir = require('lspconfig').util.root_pattern '.citc',
        settings = {},
      }
      require('lspconfig.configs').ciderlsp = {
        default_config = ciderlsp_config,
      }

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      local cmp_nvim_ciderlsp_enabled = require('lazy.core.config').plugins['cmp_nvim_ciderlsp']
      if cmp_nvim_ciderlsp_enabled then
        capabilities = require('cmp_nvim_ciderlsp').update_capabilities(capabilities)
      end
      return vim.tbl_deep_extend('force', opts, {
        servers = {
          ciderlsp = {
            capabilities = capabilities,
          },
        },
      })
    end,
    config = function(_, opts)
      -- Remove current directory from backupdir, otherwise CiderLSP can get confused
      -- and have outdated diagnostics and completions.
      vim.cmd 'set backupdir -=.'

      local lspconfig = require 'lspconfig'
      if not opts.servers or not opts.servers.ciderlsp then
        vim.notify('Unable to setup CiderLSP', vim.log.levels.WARN)
      else
        opts.servers.ciderlsp.on_attach = function(client, bufnr)
          -- TODO(b/324369022): Diagnostics don't show up when first opening a file.
          -- The below is done to remedy this, a `textDocument/didChange` call is made
          -- that gets updated diagnostics. Remove when this bug is fixed.
          client.request('textDocument/didChange', {
            textDocument = { uri = vim.uri_from_bufnr(bufnr), version = 2 },
          }, function() end)
        end
      end
      for server_name, server_opts in pairs(opts.servers or {}) do
        lspconfig[server_name].setup(server_opts)
      end
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
        },
      }
    end,
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
      'hrsh7th/cmp-cmdline',
      'onsails/lspkind.nvim',
    },
    config = function() -- :help cmp
      local sources = {
        { name = 'nvim_lsp', priority = 20 },
        { name = 'luasnip', priority = 10 },
        { name = 'buffer', priority = 1 },
        { name = 'path', priority = 1 },
        { name = 'lazydev', group_index = 0 },
      }
      if google then
        table.insert(sources, { name = 'nvim_ciderlsp', priority = 30 })
      end
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
        sources = sources,
        formatting = {
          format = require('lspkind').cmp_format {
            mode = 'symbol',
            ellipsis_char = '...',
            menu = {
              nvim_ciderlsp = '(CiderLSP)',
              nvim_lsp = '(LSP)',
              nvim_lsp_signature_help = '󰊕',
              luasnip = '(LuaSnip)',
              buffer = '(Buffer)',
              path = '(Path)',
            },
          },
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

      if google then
        require('mini.statusline').setup {
          content = {
            active = statusline_default,
          },
        }
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
      indent = { enable = false },
    },
  },
  {
    'smartpde/neoscopes',
    config = function()
      local scopes = require 'neoscopes'
      local citc_root = '/google/src/cloud/dsuo'
      if vim.loop.cwd():sub(1, #citc_root) == citc_root then
        scopes.add {
          name = 'jax',
          dirs = {
            'third_party/py/jax',
            'third_party/tensorflow',
            'experimental/users/dsuo',
          },
        }
        scopes.set_current 'jax'
      else
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

  -- [[ Google plugins ]]
  gplug {
    dir = '/usr/share/vim/google/maktaba',
    config = function()
      vim.cmd 'source /usr/share/vim/google/glug/bootstrap.vim'
    end,
  },
  gdir { dir = 'logmsgs' },
  gdir { dir = 'googler' },
  gdir {
    dir = 'codefmt-google',
    config = function(opts)
      local formatters_by_ft = {
        borg = 'gclfmt',
        gcl = 'gclfmt',
        patchpanel = 'gclfmt',
        bzl = 'buildifier',
        c = 'clang-format',
        cpp = 'clang-format',
        javascript = 'google-prettier',
        typescript = 'google-prettier',
        javascriptreact = 'google-prettier',
        typescriptreact = 'google-prettier',
        css = 'google-prettier',
        scss = 'google-prettier',
        html = 'google-prettier',
        json = 'google-prettier',
        dart = 'dartfmt',
        go = 'gofmt',
        java = 'google-java-format',
        jslayout = 'jslfmt',
        markdown = 'mdformat',
        ncl = 'nclfmt',
        python = 'pyformat',
        piccolo = 'pyformat',
        soy = 'soyfmt',
        textpb = 'text-proto-format',
        proto = 'protofmt',
        sql = 'format_sql',
        googlesql = 'format_sql',
        terraform = 'terraform',
      }
      local auto_format = {}
      for filetype in pairs(formatters_by_ft) do
        auto_format[filetype] = false
      end
      return vim.tbl_deep_extend('force', opts, {
        formatters_by_ft = formatters_by_ft,
        auto_format = auto_format,
      })
    end,
  },
  gdir {
    dir = 'codefmt',
    dependences = { 'codefmt-google' },
    cmd = { 'FormatLines', 'FormatCode', 'AutoFormatBuffer' },
    opts = {
      clang_format_executable = '/usr/bin/clang-format',
      clang_format_style = "function('codefmtgoogle#GetClangFormatStyle')",
      gofmt_executable = '/usr/lib/google-golang/bin/gofmt',
      dartfmt_executable = { '/usr/lib/google-dartlang/bin/dart', 'format' },
      ktfmt_executable = '/google/bin/releases/kotlin-google-eng/ktfmt/ktfmt',
    },
  },
  gdir { dir = 'google-filetypes', event = { 'BufReadPre', 'BufNewFile' } },
  gdir { dir = 'ft-cel', event = { 'BufReadPre *.cel,*jvp', 'BufNewFile *.cel,*jvp' } },
  gdir { dir = 'ft-clif', event = { 'BufReadPre *.clif', 'BufNewFile *.clif' } },
  gdir { dir = 'ft-gin', event = { 'BufReadPre *.gin', 'BufNewFile *.gin' } },
  gdir { dir = 'ft-gss', event = { 'BufReadPre *.gss', 'BufNewFile *.gss' } },
  gdir { dir = 'ft-proto', event = { 'BufReadPre', 'BufNewFile *.proto,*.text_proto' } },
  gdir { dir = 'ft-soy', event = { 'BufReadPre *.soy', 'BufNewFile *.soy' } },
  gdir { dir = 'ft-cpp', event = 'BufRead', 'BufNewFile *.[ch],*.cc,*.cpp' },
  gdir { dir = 'ft-go', event = 'BufRead', 'BufNewFile *.go' },
  gdir { dir = 'ft-java', event = 'BufRead', 'BufNewFile *.java' },
  gdir { dir = 'ft-javascript', event = 'BufRead', 'BufNewFile *.js,*.jsx' },
  gdir { dir = 'ft-kotlin', event = 'BufRead', 'BufNewFile *.kt,*.kts' },
  gdir { dir = 'ft-python', event = 'BufRead', 'BufNewFile *.py' },
  gdir { dir = 'googlestyle', event = { 'BufRead', 'BufNewFile' } },
  gdir { dir = 'autogen', event = 'BufNewFile' },
  gdir {
    dir = 'blaze',
    opts = {
      execution_mode = 'async',
    },
  },
  gdir { dir = 'blazedeps', event = 'BufWritePost', cmd = 'BlazeDepsUpdate' },
  gdir { dir = 'relatedfiles', cmd = 'RelatedFilesWindow' },

  gplug { url = 'sso://user/vintharas/telescope-codesearch.nvim' },
  gplug { url = 'sso://user/aktau/telescope-citc.nvim' },
  gplug { url = 'sso://team/neovim-dev/neocitc' },
  gplug { url = 'sso://user/vintharas/goog-terms.nvim' },
  gplug { url = 'sso://user/piloto/cmp-nvim-ciderlsp', opts = { override_character_triggers = true } },
  -- gplug({ url = 'sso://user/vicentecaycedo/buganizer-utils.nvim' }),
  gplug { url = 'sso://user/jackcogdill/nvim-figtree', cmd = 'Figtree' },
  -- gplug({
  --   url = 'sso://user/rprs/buganizer.nvim',
  --   dependencies = {
  --     'nvim-telescope/telescope.nvim',
  --     { url =  'sso://user/vicentecaycedo/buganizer-utils.nvim'},
  --   },
  --   cmd = { 'FindBugs', 'ShowBugsUnderCursor' },
  -- }),
  gplug {
    url = 'sso://team/neovim-dev/neocitc',
    opts = {},
    cmd = { 'CitcCreateWorkspace', 'CitcCreateFigWorkspace' },
  },
  gplug {
    url = 'sso://user/fentanes/googlepaths.nvim',
    event = { #vim.fn.argv() > 0 and 'VeryLazy' or 'UIEnter', 'BufReadCmd //*', 'BufReadCmd google3/*' },
  },
  gplug {
    url = 'sso://user/fentanes/gcert.nvim',
    dependencies = 'rcarriga/nvim-notify',
    event = #vim.fn.argv() > 0 and 'VeryLazy' or 'UIEnter',
    opts = {
      check_gcert_interval_ms = 10000,
      autorun_gcert = true,
      split_size = 12,
      show_notifications = true,
      use_nvim_notify = true,
    },
  },
  gplug {
    url = 'sso://user/smwang/hg.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'ipod825/libp.nvim',
    },
    cmd = 'Hg',
    opts = {},
    config = function()
      require('libp').setup()
      require('hg').setup()
    end,
  },
  gplug {
    url = 'sso://user/vvvv/ai.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    cmd = 'TransformCode',
  },
  gplug {
    url = 'sso://user/vintharas/goog-terms.nvim',
    enabled = vim.fn.has 'nvim-0.10.1' == 1,
    event = { 'BufRead', 'BufNewFile' },
  },
  gplug {
    url = 'sso://googler@user/cnieves/critique-nvim',
    dependencies = {
      'rktjmp/time-ago.vim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
      'runiq/neovim-throttle-debounce',
    },
    lazy = true,
    event = { 'VeryLazy' },
    config = function()
      -- Here are all the options and their default values:
      require('critique.comments').setup {
        -- Automatically fetch comments after setup and on BufEnter events.
        auto_fetch = true,
        -- If true, unresolved comments are automatically rendered when a buffer is opened.
        auto_render = true,
        -- Debounce time for throttling stubby requests to Critique, in milliseconds. Default is 10 seconds.
        debounce = 10000,
        display = {
          -- Max width in character to render a comment's text before wrapping to a newline.
          max_comment_width = 110,
          -- Render comment threads marked as resolved?
          render_resolved_threads = true,
        },
        -- Debug message level
        debug = 0,
        -- Whether or not the new comments notification includes file names.
        verbose_notifications = true,
      }
    end,
  },
  {
    url = 'sso://user/fentanes/nvgoog',
    import = 'nvgoog.default.blaze',
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
local gmap = function(keys, func, desc, mode)
  if google then
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
local find_modified_files = function()
  if string.find(vim.fn.getcwd(-1, -1), '/google/src/cloud') == 1 then
    require('telescope').extensions.citc.modified()
  else
    require('telescope.builtin').git_status()
  end
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
vim.keymap.set('i', '<C-a>', '<C-o>^')
vim.keymap.set('i', '<C-e>', '<C-o>$')
vim.keymap.set('n', '<C-a>', '0')
vim.keymap.set('n', '<C-e>', '$')
vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-e>', '<End>')

gmap('<leader>b', '[B]laze')

gmap('<leader>c', '[C]ritique')
gmap(']c', ':CritiqueGotoNextComment<CR>', 'Comment forward')
gmap('[c', ':CritiqueGotoPrevComment<CR>', 'Comment last')
gmap('<leader>ca', ':CritiqueToggleAllComments<CR>', '[C]ritique [A]ll')
gmap('<leader>cf', ':CritiqueFetchComments<CR>', '[C]ritique [F]etch')

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
gmap('<leader>ht', ':Figtree<CR>', '[H]g fig[T]ree')
gmap('<leader>hu', ':Hg uploadchain<CR>', '[H]g [U]pload chain')
gmap('<leader>ha', ':Hg amend<CR>', '[H]g [A]mend')
gmap('<leader>he', ':Hg evolve<CR>', '[H]g [E]volve')
gmap('<leader>hc', ':Hg commit<CR>', '[H]g [C]ommit')
gmap('<leader>hs', ':Hg sync<CR>', '[H]g [S]ync')

map('<leader>l', '[L]SP')
map('<leader>la', vim.lsp.buf.code_action, '[L]SP code [A]ction', { 'n', 'x' })
map('<leader>lr', vim.lsp.buf.rename, '[L]SP [R]ename')

map('<leader>n', 'Sessio[N]s')
map('<leader>nw', ':lua require("mini.sessions").write()<CR>', 'Sessio[N]s [W]rite')

map('<leader>q', vim.diagnostic.setloclist, '[Q]uickfix list')

map('<leader>s', '[S]earch')
map('<leader>sb', telescope.buffers, '[S]earch [B]uffers')
map('<leader>sc', ':CritiqueCommentsTelescope<CR>', '[S]earch [C]ritique')
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
gmap('<leader>sw', ':lua require("neocitc").pick_workspace()<CR>', '[S]earch [W]orkspace')
map(
  '<leader>sW',
  ':lua require("telescope.builtin").grep_string{ hidden = true, search_dirs = require("neoscopes").get_current_paths() }<CR>',
  '[S]earch [W]ord'
)
gmap('<leader>sx', ':RelatedFilesWindow<CR>', '[S]earch related files [X]')
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
gmap('<leader>wc', ':CitcCreateFigWorkspace ', 'Create new Fig workspace')
gmap('<leader>wp', ':CitcCreateWorkspace ', 'Create a new Piper workspace')

map('<leader>z', ':Lazy<Enter>', 'La[Z]y')

-- [[ Terminal mode ]]
map('<Esc><Esc>', '<C-\\><C-n>', 'Exit terminal mode', 't')

-- -- here are some mappings you might want:
-- local function runInTerm(cmd)
--   return function()
--     vim.g._term_calling_cmd = 1
--     vim.cmd("silent " .. cmd)
--     vim.g._term_calling_cmd = 0
--   end
-- end
-- tooltip_key = "<leader>gt",
-- action_key = "<leader>ga",
-- { "<leader>b",   desc = "Blaze" },
-- { "<leader>be",  runInTerm("call blaze#LoadErrors()"),        desc = "Blaze load errors" },
-- { "<leader>bl",  runInTerm("call blaze#ViewCommandLog()"),    desc = "Blaze view build log" },
-- { "<leader>bs",  runInTerm("BlazeGoToSponge"),                desc = "Blaze go to sponge" },
-- { "<leader>bc",  runInTerm("Blaze"),                          desc = "Blaze build on targets" },
-- { "<leader>bb",  runInTerm("Blaze build"),                    desc = "Blaze build" },
-- { "<leader>bt",  runInTerm("Blaze test"),                     desc = "Blaze test" },
-- { "<leader>bf",  runInTerm("call blaze#TestCurrentFile()"),   desc = "Blaze test current file" },
-- { "<leader>bm",  runInTerm("call blaze#TestCurrentMethod()"), desc = "Blaze test current method" },
-- { "<leader>bd",  desc = "Blaze debug" },
-- { "<leader>bdf", runInTerm("BlazeDebugCurrentFileTest"),      desc = "Blaze debug current file" },
-- { "<leader>bdm", runInTerm("BlazeDebugCurrentTestMethod"),    desc = "Blaze debug current method" },
-- { "<leader>bda", runInTerm("BlazeDebugAddBreakpoint"),        desc = "Blaze debug add breakpoint" },
-- { "<leader>bdc", runInTerm("BlazeDebugClearBreakpoint"),      desc = "Blaze debug clear breakpoint" },
-- { "<leader>bdf", runInTerm("BlazeDebugFinish"),               desc = "Blaze debug finish" },
-- { "<leader>bu", runInTerm("BlazeDepsUpdate"), desc = "Blaze update dependencies" },

-- { "[q",              "<cmd>cprev<cr>",      desc = "Goto previous quicklist item" },
-- { "]q",              "<cmd>cnext<cr>",      desc = "Goto next quicklist item" },
-- { "[Q",              "<cmd>cfirst<cr>",     desc = "Goto first quicklist item" },
-- { "]Q",              "<cmd>clast<cr>",      desc = "Goto last quicklist item" },
-- { "[l",              "<cmd>lprev<cr>",      desc = "Goto previous location list item" },
-- { "]l",              "<cmd>lnext<cr>",      desc = "Goto next location list item" },
-- { "[L",              "<cmd>lfirst<cr>",     desc = "Goto first location list item" },
-- { "]L",              "<cmd>llast<cr>",      desc = "Goto next last list item" },
-- {
--   "mhinz/vim-signify",
--   opts = {
--     updatetime = 500,
--     use_prev_commit_rev = false,
--   },
--   config = function(_, opts)
--     -- A small `updatetime` is preferred to update signs as files are updated
--     -- The default `updatetime` is 4000
--     vim.opt.updatetime = opts.updatetime
--     vim.api.nvim_set_hl(0, "SignifySignAdd", { ctermfg = "green", fg = "#79b7a5" })
--     vim.api.nvim_set_hl(0, "SignifySignChange", { ctermfg = "yellow", fg = "#ffffcc" })
--     vim.api.nvim_set_hl(0, "SignifySignChangeDelete", { ctermfg = "red", fg = "#ff7b72" })
--     vim.api.nvim_set_hl(0, "SignifySignDelete", { ctermfg = "red", fg = "#ff7b72" })
--     vim.api.nvim_set_hl(0, "SignifySignDeleteDeleteFirstLine", { ctermfg = "red", fg = "#ff7b72" })
--     if opts.use_prev_commit_rev then
--       vim.g.signify_vcs_cmds = { hg = "hg --config alias.diff=diff diff --color=never --nodates -U0 --rev .^ -- %f" }
--       vim.g.signify_vcs_cmds_diffmode = { hg = "hg cat --rev .^ %f" }
--     end
--     vim.api.nvim_create_autocmd("User", {
--       pattern = "GcertGained",
--       group = vim.api.nvim_create_augroup("vim-signify", {}),
--       callback = function()
--         vim.cmd("SignifyEnableAll")
--       end,
--     })
--   end,
--   keys = {
--     { "[c", "<Plug>(signify-prev-hunk)",            desc = "Goto previous hunk" },
--     { "]c", "<Plug>(signify-next-hunk)",            desc = "Goto next hunk" },
--     { "[C", "<cmd>normal 9999[c<cr>",               desc = "Goto first hunk" },
--     { "]C", "<cmd>normal 9999]c<cr>",               desc = "Goto last hunk" },
--     { "ic", "<Plug>(signify-motion-inner-pending)", desc = "Hunk text object",  mode = "o" },
--     { "ic", "<Plug>(signify-motion-inner-visual)",  desc = "Hunk text object",  mode = "x" },
--     { "ac", "<Plug>(signify-motion-outer-pending)", desc = "Hunk text object",  mode = "o" },
--     { "ac", "<Plug>(signify-motion-outer-pending)", desc = "Hunk text object",  mode = "x" },
--   },
-- },
