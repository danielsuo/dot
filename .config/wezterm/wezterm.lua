local wezterm = require 'wezterm';

local config = wezterm.config_builder()

config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = true
config.use_ime = false
config.debug_key_events = true

return config
