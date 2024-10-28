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

M.display_shell_command = function(command, opts)
  local buf = vim.api.nvim_create_buf(false, true)
  local dim = create_float()
  local win = vim.api.nvim_open_win(buf, true, vim.tbl_deep_extend("force", { relative = "editor", border = "single" }, dim))
  local on_exit = function ()
    if opts and opts.on_exit then
      opts.on_exit()
    end
    vim.api.nvim_win_close(win, true)
  end
  vim.fn.termopen(command, {
    buf = buf,
    detach = false,
    on_exit = on_exit,
  })
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_set_current_buf(buf)  -- Rend ce buffer le buffer actif
  vim.cmd("startinsert")  -- Passe en mode insert
end

M.make_display_shell_command = function(command)
  return function() M.display_shell_command(command) end
end

local function is_buf_edited(buf)
  return vim.api.nvim_get_option_value("modified", {buf = buf})
end

M.compare_with_saved = function()
  local path = vim.api.nvim_buf_get_name(0)
  if not vim.fn.filereadable(path) then
    vim.notify("This is not a file", nil)-- "error")
    return
  end
  if not is_buf_edited(0) then
    vim.notify("Buffer is not edited", nil)-- "error")
    return
  end
  local content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local path_file_minus = os.tmpname()
  local file_minus = io.open(path_file_minus, "w")
  if file_minus == nil then
    vim.notify("unable to write in a temporary file")
    return
  end
  file_minus:write(table.concat(content, "\n"))
  file_minus:close()
  local delta_options = vim.g.DELTA_OPTIONS or ""
  local cmd = "delta --paging=always " .. delta_options .. " '" .. path .. "' '" .. path_file_minus .. "'"
  vim.notify("cmd compare: "..cmd)
  M.display_shell_command(cmd, {
    on_exit = function() os.remove(path_file_minus) end
  })
end

return M
