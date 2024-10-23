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
require("user.config")

require("mini.splitjoin").setup()
require("mini.move").setup()
require("mini.surround").setup()
require("mini.comment").setup()

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
local function move_selection(direction)
  local count = vim.v.count1
  if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
    -- Étendre la sélection à des lignes complètes
    vim.cmd("normal! gvV")
    if direction == "up" then
      vim.cmd("'<,'>move '<-" .. (count + 1))
    else
      vim.cmd("'<,'>move '>+" .. count)
    end
    -- Re-sélectionner les lignes déplacées
    vim.cmd("normal! gv=gv")
  else
    -- Mode normal
    if direction == "up" then
      vim.cmd("move .-" .. (count + 1))
    else
      vim.cmd("move .+" .. count)
    end
    -- Réaligner la ligne
    vim.cmd("normal! ==")
  end
end

vim.keymap.set({ "n", "x" }, "<M-k>", function()
  move_selection("up")
end, { silent = true })
vim.keymap.set({ "n", "x" }, "<M-j>", function()
  move_selection("down")
end, { silent = true })
