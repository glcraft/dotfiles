-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("neo-tree").setup({
  source_selector = {
    winbar = true,
    statusline = false,
    sources = {
      { source = "filesystem" },
      { source = "buffers" },
      { source = "git_status" },
      { source = "document_symbols" },
    },
  },
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
  },
})

require("user.reload-init")

-- set color scheme from local time
local time = vim.fn.localtime()
local hours = math.floor(time / 60 / 60 % 24)
vim.cmd("colorscheme vscode")
if hours >= 10 and hours <= 17 then -- GMT time
  -- vim.cmd("colorscheme catppuccin-latte")
  vim.o.background = "light"
else
  -- vim.cmd("colorscheme catppuccin-mocha")
  vim.o.background = "dark"
end

-- bind move to m for down and M for up in normal and visual mode
vim.keymap.set("n", "M", "ddkP")
vim.keymap.set("n", "m", "ddp")
-- vim.keymap.set("v", "M", "dkp")
-- vim.keymap.set("v", "m", "dp")
