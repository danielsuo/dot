local wezterm = require("wezterm")
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

local config = wezterm.config_builder()
local act = wezterm.action

config.use_ime = false
config.debug_key_events = true
config.disable_default_key_bindings = true
config.term = "xterm-256color"

config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "n", mods = "SUPER", action = act.SpawnWindow },
	{ key = "q", mods = "SUPER", action = act.QuitApplication },
	{ key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "[", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "SUPER|SHIFT", action = act.ActivateTabRelative(1) },
	{ key = "r", mods = "SUPER", action = act.ReloadConfiguration },
	{ key = "f", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "\\", mods = "LEADER", action = act.SplitPane({ direction = "Right", size = { Percent = 50 } }) },
	{ key = "-", mods = "LEADER", action = act.SplitPane({ direction = "Down", size = { Percent = 50 } }) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	-- Swap active pane with another one
	{ key = "s", mods = "LEADER", action = act.PaneSelect({ mode = "SwapWithActiveKeepFocus" }) },
}

smart_splits.apply_to_config(config, {
	direction_keys = { "h", "j", "k", "l" },
	modifiers = { move = "CTRL", resize = "ALT" },
	log_level = "info",
})

return config
