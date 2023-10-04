-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap(
  "n",
  "<leader>ut",
  "<cmd>lua ReloadConfig()<CR>",
  { noremap = true, silent = false, desc = "Reload lua config" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>uS",
  "<cmd>mksession!<CR>",
  { noremap = true, silent = false, desc = "Save session" }
)
vim.api.nvim_set_keymap(
  "n",
  "<leader>uR",
  "<cmd>source Session.vim<CR>",
  { noremap = true, silent = false, desc = "Load session" }
)
