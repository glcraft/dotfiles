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
  "<leader>L",
  "<cmd> Lazy <cr>",
  mode = { "n", "i", "v" },
  desc = "lazy.nvim",
  icon = ""
}
wk.add {
  "<leader>l",
  require("frameterm").make_display_shell_command("lazygit"),
  mode = { "n", "i", "v" },
  desc = "lazygit",
  icon = "󰊢"
}
wk.add {
  "<C-:>",
  "gcc",
  mode = { "n" },
  desc = "Toggle comment",
}
wk.add {
  "<C-:>",
  "gc",
  mode = { "v" },
  desc = "Toggle comment",
}

wk.add {
  "s",
  "<Nop>",
  group = "surround",
  -- noremap = true,
}
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- map({ "n", "i", "v" }, "<leader>L", "<cmd> Lazy <cr>", { desc = "󰊢 lazy.nvim" })
-- map({ "n", "i", "v" }, , { desc = "󰊢 lazygit" })
