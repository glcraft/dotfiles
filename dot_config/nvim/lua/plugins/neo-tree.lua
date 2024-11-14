return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = {
      popup_border_style = 'rounded',
      sources = {
        "filesystem",
        "buffers",
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_gitignored = false,
          hide_hidden = false,
          hide_dotfiles = false,
        },
        follow_current_file = {
          enabled = true
        },
      }
    },
    opt = {
      auto_clean_after_session_restore = true,
    }
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false
  },
}
