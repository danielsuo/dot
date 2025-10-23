local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")


local config = wezterm.config_builder()
local act = wezterm.action

-- Functions
local set_active_tab_title = function(window, pane, line)
  if line then
    window:active_tab():set_title(line)
  end
end

SetActiveTabTitle = act.PromptInputLine {
  description = 'Enter new name for tab',
  action = wezterm.action_callback(set_active_tab_title),
}

-- UI
config.pane_focus_follows_mouse = true
config.use_fancy_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true
config.scrollback_lines = 5000
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0, }
config.colors = { tab_bar = { active_tab = { fg_color = '#073642', bg_color = '#2aa198' } } }
config.use_ime = false
config.debug_key_events = true
config.disable_default_key_bindings = true

-- Keybindings
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
  { key = "c",  mods = "SUPER",       action = act.CopyTo("Clipboard") },
  { key = "n",  mods = "SUPER",       action = act.SpawnWindow },
  { key = "q",  mods = "SUPER",       action = act.QuitApplication },
  { key = "t",  mods = "SUPER",       action = act.SpawnTab("CurrentPaneDomain") },
  { key = "v",  mods = "SUPER",       action = act.PasteFrom("Clipboard") },
  { key = "w",  mods = "SUPER",       action = act.CloseCurrentTab({ confirm = true }) },
  { key = "[",  mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "]",  mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },
  { key = "r",  mods = "SUPER",       action = act.ReloadConfiguration },
  { key = "f",  mods = "LEADER",      action = act.TogglePaneZoomState },
  { key = "\\", mods = "LEADER",      action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
  { key = "-",  mods = "LEADER",      action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
  { key = "x",  mods = "LEADER",      action = act.CloseCurrentPane({ confirm = true }) },
  { key = "s",  mods = "LEADER",      action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
  { key = ',',  mods = 'LEADER',      action = SetActiveTabTitle },
  { key = 'g',  mods = 'LEADER',      action = act.PaneSelect( { show_pane_ids = false, }) },
}
smart_splits.apply_to_config(config, {
  direction_keys = { "h", "j", "k", "l" },
  modifiers = { move = "CTRL", resize = "ALT" },
  log_level = "info",
})

-- Sessions
config.unix_domains = { { name = "unix" } }

return config
