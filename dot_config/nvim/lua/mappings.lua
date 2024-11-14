require "nvchad.mappings"

-- add yours here

local wk = require("which-key")
wk.add({
  {
    "<C-s>",
    "<cmd> w <cr>",
    mode = { "n", "i", "v" },
    desc = "Save the file",
  },
  {
    "<C-a>",
    "ggVG",
    mode = { "n", "i", "v" },
    desc = "Select all",
  },
  {
    "<leader>M",
    "<cmd> Mason <cr>",
    mode = { "n", "v" },
    desc = "mason",
    icon = ""
  },
  {
    "<leader>L",
    "<cmd> Lazy <cr>",
    mode = { "n", "v" },
    desc = "lazy.nvim",
    icon = ""
  },
  {
    "<leader>G",
    require("frameterm").make_display_shell_command("lazygit"),
    group = nil,
    mode = { "n", "v" },
    desc = "lazygit",
    icon = "󰊢"
  },
  {
    "<C-;>",
    "gcc",
    mode = { "n" },
    desc = "Toggle comment",
  },
  {
    "<C-;>",
    "gc",
    mode = { "v" },
    desc = "Toggle comment",
  },
  {
    "s",
    "<Nop>",
    group = "surround",
    { "sa", desc = "Add surrouding" },
    { "sd", desc = "Remove surrouding" },
  },
  {
    "<leader>fs",
    require("frameterm").compare_with_saved,
    mode = { "n", "v" },
    desc = "Compare with saved",
  },
  {
    "<leader>e",
    "<cmd>Neotree toggle<cr>",
    mode = { "n", "v" },
    desc = "Toggle Neo-Tree",
  },
  {
    "<f12>",
    "<cmd>Definitions<cr>",
    mode = { "n", "v" },
    desc = "Show definitions",
  },
})

wk.add({
  {
    "<leader>f",
    group = "Telescope",
    { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Telescope notifications" },
    {
      "<leader>fg",
      group = "Telescope git",
      { "<leader>fgs", "<cmd>Telescope git_status<cr>", desc = "git status" },
      { "<leader>fgf", "<cmd>Telescope git_files<cr>", desc = "git files" },
      { "<leader>fgc", "<cmd>Telescope git_commits<cr>", desc = "git commits" },
      { "<leader>fgb", "<cmd>Telescope git_branches<cr>", desc = "git branches" },

    }
  },
})

wk.add({
  "<leader>l",
  group = "LSP",
  { "<leader>ld", "<cmd>Definitions<cr>", desc = "Show definitions" },
  { "<leader>lr", "<cmd>References<cr>", desc = "Show references" },
  { "<leader>lc", "<cmd>CodeActions<cr>", desc = "Show code action" },
  { "<leader>ls", "<cmd>DocumentSymbols<cr>", desc = "Show document symbols" },
  { "<leader>lS", "<cmd>WorkspaceSymbols<cr>", desc = "Show all symbols" },
  { "<leader>lw", "<cmd>Diagnostics<cr>", desc = "Show document diagnostics" },
  { "<leader>lW", "<cmd>DiagnosticsAll<cr>", desc = "Show all diagnostics" },
})
