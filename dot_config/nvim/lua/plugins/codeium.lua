return {
  "Exafunction/codeium.vim",
  event = "BufEnter",
  config = function()
    -- vim.keymap.set("i", "<C-a>", "<cmd>call codeium#Accept()<CR>", { desc = "Codeium: Accept" })
    vim.keymap.set(
      "i",
      "<C-a>",
      "codeium#Accept()",
      { desc = "Codeium: Accept", silent = true, expr = true, nowait = true, script = true }
    )
  end,
  -- config = function()
  --   vim.keymap.set("i", "<C-a>", function()
  --     return vim.fn["codeium#Accept"]()
  --   end, { expr = true, desc = "Codeium : Accept" })
  -- end,
}
