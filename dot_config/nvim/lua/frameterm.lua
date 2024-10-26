-- https://github.com/NvChad/ui/blob/v3.0/lua/nvchad/term/init.lua
local nvconfig = require "nvconfig"
local config = nvconfig.term.float or nvconfig.ui.term

local M = {}

local function create_float()
  local opts = {}
  opts.width =  math.ceil(config.width * vim.o.columns)
  opts.height = math.ceil(config.height * vim.o.lines)
  opts.row =    math.ceil(config.row * vim.o.lines)
  opts.col =    math.ceil(config.col * vim.o.columns)
  return opts
end

M.display_shell_command = function(command)
  local buf = vim.api.nvim_create_buf(false, true)
  local dim = create_float()
  local win = vim.api.nvim_open_win(buf, true, vim.tbl_deep_extend("force", { relative = "editor", border = "single" }, dim))
  vim.fn.termopen("lazygit", {
    buf = buf,
    detach = false,
    on_exit = function() vim.api.nvim_win_close(win, true) end
  })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_set_current_buf(buf)  -- Rend ce buffer le buffer actif
  vim.cmd("startinsert")  -- Passe en mode insert
end

M.make_display_shell_command = function(command)
  return function() M.display_shell_command(command) end
end 

return M
