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
if hours >= 10 and hours <= 17 then -- GMT time
  vim.cmd("colorscheme catppuccin-latte")
else
  vim.cmd("colorscheme catppuccin-mocha")
end
