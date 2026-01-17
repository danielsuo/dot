local M = {}

function M.bootstrap_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
      "https://github.com/folke/lazy.nvim.git", lazypath })
  end
  vim.opt.rtp:prepend(lazypath)
end

M.triggers = {}
M.clues = {}

function M.triggers_for(mode, keys_list)
  for _, key in ipairs(keys_list) do
    table.insert(M.triggers, { mode = mode, keys = key })
  end
end

function M.clues_for(clues_list)
  for _, clue in ipairs(clues_list) do
    table.insert(M.clues, clue)
  end
end

function M.map(mode, keys, cmd, desc)
  if cmd then
    vim.keymap.set(mode, keys, cmd, { desc = desc })
  else
    table.insert(M.clues, { mode = mode, keys = keys, desc = desc })
  end
end

function M.statuscolumn()
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum
  local total = vim.fn.line('$')
  vim.b.statuscolumn_lnum_width = math.max(#tostring(total), 3)
  vim.b.statuscolumn_relnum_width = math.max(#tostring(math.floor(vim.fn.winheight(0) / 2) + 1), 2)
  local lnum_width = vim.b.statuscolumn_lnum_width or 4
  local relnum_width = vim.b.statuscolumn_relnum_width or 2
  return string.format("%" .. lnum_width .. "d %" .. relnum_width .. "d│", lnum, relnum)
end

return M
