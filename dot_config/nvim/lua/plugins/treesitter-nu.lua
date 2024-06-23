return {
  "nvim-treesitter/nvim-treesitter",
  config = function()
    -- setup treesitter with config
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "nu" },
      highlight = {
        enable = true,
      },
    })
  end,
  dependencies = {
    -- NOTE: additional parser
    { "nushell/tree-sitter-nu" },
  },
  build = ":TSUpdate",
}
