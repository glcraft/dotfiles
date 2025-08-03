local wezterm = require 'wezterm'

local utils = require 'utils'
string.startswith = utils.string_startswith

local function make_ide(pane)
  -- local actions = {}
  -- for _, v_pane in ipairs(pane:tab():panes()) do
  --   if pane:id() ~= v_pane:id() then
  --   end
  -- end
  local cwd = pane:get_current_working_dir()
  pane:split({
    cwd = cwd,
    args = {"lazygit"},
    direction = "Right",
    size = 1/3
  }):split({
    cwd = cwd,
    args = {"yazi"},
    set_environment_variables = {
      HELIX_PANE = tostring(pane:pane_id()),
      YAZI_CONFIG_HOME = "~/.config/yazi/wezterm",
    },
    direction = "Bottom",
  }):split({
    cwd = cwd,
    direction = "Bottom"
  })
end

local config = wezterm.config_builder()

-- initial geometry for new windows
config.initial_cols = 120
config.initial_rows = 28

-- Appearance
config.font_size = 12
config.color_scheme = 'AdventureTime'
config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.background = {
  {
    source = {File="/Users/gly/Pictures/Backgrounds/wp4615518-terminal-wallpapers.jpg"},
    hsb = { brightness = 0.7 },
  }
}

if utils.host_os == "macos" then
  config.set_environment_variables = {
    PATH = '/opt/homebrew/bin:' .. os.getenv('PATH')
  }
end

-- Program launcher
config.default_prog = {"/opt/homebrew/bin/nu", "-l"}
config.launch_menu = {
  {
    label = "zsh",
    args = {"zsh", "-l"}
  },
  {
    label = "Bottom - Process manager",
    args = {"btm"},
  },
  {
    label = "Helix",
    args = { "hx" }
  }
}

config.keys = {}

if utils.host_os == "macos" then
  -- Home/End behavior on MacOS
  table.insert(config.keys, {
    key = 'LeftArrow',
    mods = 'CMD',
    action = wezterm.action { SendString = "\x1bOH" },
  })
  table.insert(config.keys, {
    key = 'RightArrow',
    mods = 'CMD',
    action = wezterm.action { SendString = "\x1bOF" },
  })
  -- Delete whole line
  table.insert(config.keys, {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action { SendString = "\x15", },
  })
end
table.insert(config.keys, {
  key = 'J',
  mods = 'CMD|SHIFT',
  action = wezterm.action_callback(function(win, pane)
    make_ide(pane)
  end)
})

-- Open file in helix
config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
  regex = [[([a-zA-Z]:[\\/]|/)?([a-zA-Z0-9\.\-_@]+[\\/])*([a-zA-Z0-9\.\-_@]+)(:\d+):(\d+)]],
  format = 'file://$0',
})
table.insert(config.hyperlink_rules, {
  regex = [[^([a-zA-Z]:[\\/]|/)([a-zA-Z0-9\.\-_@]+[\\/])+([a-zA-Z0-9\.\-_@]+)]],
  format = 'file://$0',
})
wezterm.on('open-uri', function(window, pane, uri)
  if uri:startswith('file://') then
    local direction = 'Left'
    local hx_pane
    for _, v_pane in ipairs(pane:tab():panes()) do
      local process_name = v_pane:get_foreground_process_name()
      local program = process_name:sub(1, process_name:find(' ') or #process_name)
      local program_name = utils.path_basename(program)
      if program_name == "hx" or program_name == "helix" then
        hx_pane = v_pane
      end
    end
    local action
    if hx_pane == nil then
      hx_pane = pane
      action = wezterm.action.SplitPane {
        direction = direction,
        command = {
          args = { 'hx', uri:sub(8) },
        },
      }
    else
      action = wezterm.action.SendString(':open ' .. uri:sub(8) .. '\r\n')
    end
    if action then
      window:perform_action(action, hx_pane)
    end
  end
  return false
end)

-- Finally, return the configuration to wezterm:
return config
