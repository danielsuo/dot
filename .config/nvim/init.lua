local util = require("util")
util.bootstrap_lazy()

-- Keybindings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

util.map("n", "<leader>f", nil, "+File")
util.map("n", "<leader>fs", ":w<cr>", "Save")
util.map("n", "<leader>fq", ":q<cr>", "Quit")

util.map("n", "<leader>s", nil, "+Search")
util.map("n", "<leader>sf", "<cmd>Telescope find_files hidden=true<cr>", "Files")
util.map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", "Grep")
util.map("n", "<leader>sb", "<cmd>Telescope buffers<cr>", "Buffers")
util.map("n", "<leader>sh", "<cmd>Telescope help_tags<cr>", "Help")
util.map("n", "<leader>sr", "<cmd>Telescope oldfiles<cr>", "Recent")
util.map("n", "<leader>se", "<cmd>Telescope file_browser<cr>", "Explorer")
util.map("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", "Keymaps")
util.map("n", "<leader>sc", "<cmd>Telescope commands<cr>", "Commands")

util.map("n", "<leader>l", nil, "+LSP")
util.map("n", "<leader>ld", vim.lsp.buf.definition, "Definition")
util.map("n", "<leader>lr", vim.lsp.buf.references, "References")
util.map("n", "<leader>lh", vim.lsp.buf.hover, "Hover")
util.map("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
util.map("n", "<leader>ln", vim.lsp.buf.rename, "Rename")
util.map("n", "<leader>le", vim.diagnostic.open_float, "Diagnostics")
util.map("n", "<leader>lq", "<cmd>cclose<cr>", "Close Quickfix")
util.map("n", "<leader>ll", vim.diagnostic.setqflist, "List All Diagnostics")

-- mini.clue
util.triggers_for("n", { "<Leader>", "g", "z", "'", "`", '"', "<C-w>", "[", "]" })
util.triggers_for("x", { "<Leader>", "g", "z", "'", "`", '"', "[", "]" })
util.triggers_for("i", { "<C-r>", "<C-x>" })
util.triggers_for("c", { "<C-r>" })

local function config_miniclue()
  local miniclue = require("mini.clue")
  util.clues_for({
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  })
  miniclue.setup({
    triggers = util.triggers,
    clues = util.clues,
    window = {
      delay = 0,
      config = { width = "auto" },
    },
  })
end

-- telescope
local function config_telescope()
  require("telescope").setup({})
  require("telescope").load_extension("fzf")
  require("telescope").load_extension("file_browser")
end

-- treesitter
local function config_treesitter()
  require("nvim-treesitter").setup({
    ensure_installed = { "lua", "python", "vim", "vimdoc", "query" },
  })
end


-- lsp
local function config_lsp()
  require("mason").setup()
  require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "pyright", "ruff" },
  })

  -- Neovim 0.11+ native LSP config
  vim.lsp.config.lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  }
  vim.lsp.config.pyright = {}
  vim.lsp.config.ruff = {
    capabilities = {
      definitionProvider = false,
      referencesProvider = false,
    },
  }

  vim.lsp.enable({ "lua_ls", "pyright", "ruff" })
end

-- Plugins
require("lazy").setup({
  { "echasnovski/mini.clue", event = "VeryLazy", config = config_miniclue },
  { "nvim-lua/plenary.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "nvim-telescope/telescope-file-browser.nvim" },
  { "nvim-telescope/telescope.nvim", branch = "0.1.x", config = config_telescope },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", config = config_treesitter },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig", config = config_lsp },
  { "navarasu/onedark.nvim" },
  { "lewis6991/satellite.nvim", config = function() require("satellite").setup() end },
})

-- Theme
vim.cmd("colorscheme onedark")

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = '%{%v:lua.require("util").statuscolumn()%}'
