-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "bearded-arc",
  theme_toggle = { "bearded-arc", "flex-light" },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                            ",
    "     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
    "   ▄▀███▄     ▄██ █████▀    ",
    "   ██▄▀███▄   ███           ",
    "   ███  ▀███▄ ███           ",
    "   ███    ▀██ ███           ",
    "   ███      ▀ ███           ",
    "   ▀██ █████▄▀█▀▄██████▄    ",
    "     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
    "                            ",
    "     Powered By  eovim    ",
    "                            ",
  },

  buttons = {
    { txt = "  New Buffer", keys = "b", cmd = "enew" },
    { txt = "  Find File", keys = "ff", cmd = "Telescope find_files" },
    { txt = "  Recent Files", keys = "fo", cmd = "Telescope oldfiles" },
    { txt = "󰈭  Find Word", keys = "fw", cmd = "Telescope live_grep" },
    { txt = "󱥚  Themes", keys = "th", cmd = ":lua require('nvchad.themes').open()" },
    { txt = "  Mappings", keys = "ch", cmd = "NvCheatsheet" },
    { txt = "  Config", keys = "cc", cmd = "cd ~/.config/nvim/ | Telescope find_files" },
    { txt = "  lazy.nvim", keys = "l", cmd = "Lazy" },
    { txt = "󰅙  Quit", keys = "q", cmd = "quit" },

    { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },

    {
      txt = function()
        local stats = require("lazy").stats()
        local ms = math.floor(stats.startuptime) .. " ms"
        return "  Loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms
      end,
      hl = "NvDashLazy",
      no_gap = true,
    },

    { txt = "─", hl = "NvDashLazy", no_gap = true, rep = true },
  },
}

M.term = {
  float = {
    col = 0.1,
    row = 0.075,
    width = 0.8,
    height = 0.8,
  }
}

local function getNeoTreeWidth()
  local api = vim.api
  for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
    if vim.bo[api.nvim_win_get_buf(win)].ft == "neo-tree" then
      return api.nvim_win_get_width(win) + 1
    end
  end
  return 0
end

M.ui = {
   tabufline = {
     order = { "neotreeOffset", "buffers", "tabs", "btns" },
     modules = {
       neotreeOffset = function()
          return "%#NeoTreeNormal#" .. string.rep(" ", getNeoTreeWidth())
       end,
     }
   }
 }


return M
