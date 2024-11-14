return {
  {
    'nvim-telescope/telescope.nvim',
    -- opts = overrides.telescope,
    config = function()
      dofile(vim.g.base46_cache .. 'telescope')

      local telescope = require('telescope')

      telescope.setup({})
      telescope.load_extension('fzf')
      telescope.load_extension('lsp_handlers')
      -- telescope.load_extension('dap')
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -G "Ninja" -DCMAKE_BUILD_TYPE=Release; cmake --build build --config Release',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
  },
  {
    'nvim-telescope/telescope-dap.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    }
  },
  {
    'gbrlsnchs/telescope-lsp-handlers.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
  },
}

