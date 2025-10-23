local wezterm = require ('wezterm')
local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')


local config = wezterm.config_builder()

config.debug_key_events = true
config.disable_default_key_bindings = true
config.term = "xterm-256color"

config.keys = {
  { key = 'c', mods = 'SUPER',       action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'n', mods = 'SUPER',       action = wezterm.action.SpawnWindow },
  { key = 'q', mods = 'SUPER',       action = wezterm.action.QuitApplication },
  { key = 't', mods = 'SUPER',       action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'v', mods = 'SUPER',       action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'w', mods = 'SUPER',       action = wezterm.action.CloseCurrentTab { confirm = true } },
  { key = '[', mods = 'SUPER|SHIFT', action = wezterm.action.ActivateTabRelative(-1) },
  { key = ']', mods = 'SUPER|SHIFT', action = wezterm.action.ActivateTabRelative(1) },
  { key = 'r', mods = 'CTRL|SHIFT',  action = wezterm.action.ReloadConfiguration },

  { key = "h", mods = "SHIFT|SUPER",  action = wezterm.action.SendString('\x1b[72;14u') },
}

return config
