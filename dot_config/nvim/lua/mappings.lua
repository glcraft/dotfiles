require "nvchad.mappings"

-- add yours here

local wk = require("which-key")

wk.add {
  "<C-s>",
  "<cmd> w <cr>",
  mode = { "n", "i", "v" },
  desc = "Save the file",
}
wk.add {
  "<leader>M",
  "<cmd> Mason <cr>",
  mode = { "n", "v" },
  desc = "mason",
  icon = ""
}
wk.add {
  "<leader>L",
  "<cmd> Lazy <cr>",
  mode = { "n", "v" },
  desc = "lazy.nvim",
  icon = ""
}
wk.add {
  "<leader>l",
  require("frameterm").make_display_shell_command("lazygit"),
  mode = { "n", "v" },
  desc = "lazygit",
  icon = "󰊢"
}
wk.add {
  "<C-/>",
  "gcc",
  mode = { "n" },
  desc = "Toggle comment",
}
wk.add {
  "<C-/>",
  "gc",
  mode = { "v" },
  desc = "Toggle comment",
}
-- vim.keymap.set( {"n"}, "<C-/>", "gcc")
wk.add {
  "s",
  "<Nop>",
  group = "surround",
  -- noremap = true,
}
wk.add {
  "<leader>fs",
  require("frameterm").compare_with_saved,
  mode = { "n", "v" },
  desc = "Compare with saved",
  -- icon = "󰊢"
}
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- map({ "n", "i", "v" }, "<leader>L", "<cmd> Lazy <cr>", { desc = "󰊢 lazy.nvim" })
-- map({ "n", "i", "v" }, , { desc = "󰊢 lazygit" })
