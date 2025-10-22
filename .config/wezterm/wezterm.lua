local wezterm = require 'wezterm';

local config = wezterm.config_builder()

config.debug_key_events = true
config.disable_default_key_bindings = true

config.keys = {
  { key = 'n', mods = 'SUPER', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'SUPER', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'SUPER', action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = 'q', mods = 'SUPER', action = wezterm.action.QuitApplication },
  { key = '[', mods = 'SUPER|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'SUPER|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
}

return config
