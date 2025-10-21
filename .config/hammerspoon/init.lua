require('hs.ipc')

hs.loadSpoon('URLDispatcher')

hyper = { 'cmd', 'alt', 'ctrl', 'shift' }

spoon.URLDispatcher:start()
hs.window.animationDuration = 0


local launch_app = function(app)
	return function()
		hs.application.launchOrFocus(app)
	end
end

-- Window management
local move_window_to_next_screen = function()
  -- get the focused window
  local win = hs.window.focusedWindow()
  -- get the screen where the focused window is displayed, a.k.a. current screen
  local screen = win:screen()
  -- compute the unitRect of the focused window relative to the current screen
  -- and move the window to the next screen setting the same unitRect 
  win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end

local move_window_to_prev_screen = function()
  -- get the focused window
  local win = hs.window.focusedWindow()
  -- get the screen where the focused window is displayed, a.k.a. current screen
  local screen = win:screen()
  -- compute the unitRect of the focused window relative to the current screen
  -- and move the window to the next screen setting the same unitRect 
  win:move(win:frame():toUnitRect(screen:frame()), screen:previous(), true, 0)
end

-- Web
local dispatch_url = function(url)
	return function()
		spoon.URLDispatcher:dispatchURL('', '', '', 'https://' .. url, -1)
	end
end

local GRID_SIZE = 4
local HALF_GRID_SIZE = GRID_SIZE / 2
hs.grid.setGrid(GRID_SIZE .. 'x' .. GRID_SIZE)
hs.grid.setMargins({0, 0})
hs.window.animationDuration = 0

local screenPositions = {}
screenPositions.full  = {x = 0, y = 0, w = GRID_SIZE, h = GRID_SIZE }
screenPositions.left  = {x = 0, y = 0, w = HALF_GRID_SIZE, h = GRID_SIZE }
screenPositions.right = {x = HALF_GRID_SIZE, y = 0, w = HALF_GRID_SIZE, h = GRID_SIZE }
screenPositions.middle = {x = GRID_SIZE / 3, y= 0, w = HALF_GRID_SIZE, h = GRID_SIZE }

function moveWindowToPosition(cell, window)
  if window == nil then
    window = hs.window.focusedWindow()
  end
  if window then
    local screen = window:screen()
    hs.grid.set(window, cell, screen)
  end
end

-- Multimedia
function change_volume(diff)
	return function()
		local current = hs.audiodevice.defaultOutputDevice():volume()
		local new = math.min(100, math.max(0, math.floor(current + diff)))
		if new > 0 then
			hs.audiodevice.defaultOutputDevice():setMuted(false)
		end
		hs.alert.closeAll(0.0)
		hs.alert.show('Volume ' .. new .. '%', {}, 0.5)
		hs.audiodevice.defaultOutputDevice():setVolume(new)
	end
end

local toggle_mute = function()
	mute = not hs.audiodevice.defaultOutputDevice():muted()
	hs.audiodevice.defaultOutputDevice():setMuted(mute)
	hs.alert.closeAll(0.0)
	if mute then
		hs.alert.show('Muted')
	else
		hs.alert.show('Unmuted')
	end
end

-- HYPER
--
-- Hyper is a hyper shortcut modal.
--
-- Feel free to modify... I use karabiner-elements.app on my laptop and QMK on
-- my mech keyboards to bind a single key to `F19`, which fires all this
-- Hammerspoon-powered OSX automation.
--
-- I chiefly use it to launch applications quickly from a single press,
-- although I also use it to create 'universal' local bindings inspired by
-- Shawn Blanc's OopsieThings.
-- https://thesweetsetup.com/oopsiethings-applescript-for-things-on-mac/
--
-- Optional:
-- Hyper hooks into Headspace's block lists. If you configure a space using
-- Headspace, it'll block launching apps that are currently on the blocked
-- lists via hs.settings.

local hyper = hs.hotkey.modal.new({}, nil)

hyper.pressed = function()
	hyper.key_pressed_in_modal = false
  hyper:enter()
end

hyper.released = function()
  hyper:exit()
	if not hyper.key_pressed_in_modal then
    hs.eventtap.keyStroke({}, 'escape')
  end
end

-- Set the key you want to be HYPER to F19 in karabiner or keyboard
-- Bind the Hyper key to the hammerspoon modal
hs.hotkey.bind({}, 'F19', hyper.pressed, hyper.released)

hyper.allowed = function(app)
  if app.tags then
    if hs.settings.get('only') then
      return hs.fnutils.some(hs.settings.get('only'), function(tag)
        return hs.fnutils.contains(app.tags, tag)
      end)
    else
      if hs.settings.get('never') then
        return hs.fnutils.every(hs.settings.get('never'), function(tag)
          return not hs.fnutils.contains(app.tags, tag)
        end)
      end
    end
  end
  return true
end

hyper.launch = function(app)
  if hyper.allowed(app) then
    hs.application.launchOrFocusByBundleID(app.bundleID)
  else
    hs.notify.show('Blocked ' .. app.bundleID, 'You have to switch headspaces', '')
  end
end

-- Expects a configuration table with an applications key that has the
-- following form:
-- config_table.applications = {
--   ['com.culturedcode.ThingsMac'] = {
--     bundleID = 'com.culturedcode.ThingsMac',
--     hyper_key = 't',
--     tags = {'#planning', '#review'},
--     local_bindings = {',', '.'}
--   },
-- }
hyper.start = function(config_table)
  -- Use the hyper key with the application config to use the `hyper_key`
  for _, app in pairs(config_table.applications) do
    -- Apps that I want to jump to
    if app.hyper_key then
      hyper:bind({}, app.hyper_key, function()
				hyper.key_pressed_in_modal = true
				hyper.launch(app);
			end)
    end

    -- I use hyper to power some shortcuts in different apps If the app is closed
    -- and I press the shortcut, open the app and send the shortcut, otherwise
    -- just send the shortcut.
    if app.local_bindings then
      for _, key in pairs(app.local_bindings) do
        hyper:bind({}, key, nil, function()
				  hyper.key_pressed_in_modal = true
          if hs.application.find(app.bundleID) then
            hs.eventtap.keyStroke({'cmd','alt','shift','ctrl'}, key)
          else
            hyper.launch(app)
            hs.timer.waitWhile(
              function() return hs.application.find(app.bundleID) == nil end,
              function()
                hs.eventtap.keyStroke({'cmd','alt','shift','ctrl'}, key)
              end)
          end
        end)
      end
    end
  end
end

config = {}
config.applications = {
  ['Homerow'] = {
    bundleID = 'com.superultra.Homerow',
    local_bindings = {'space'}
  },
}
hyper.start(config)

hyper:bind({}, 'A', launch_app('Activity Monitor'))
hyper:bind({}, 'B', dispatch_url('b.corp.google.com/home'))
hyper:bind({}, 'C', launch_app('Google Chrome'))
hyper:bind({}, 'E', dispatch_url('goto2.corp.google.com/sknow'))
hyper:bind({}, 'F', launch_app('Finder'))
hyper:bind({}, 'G', dispatch_url('github.com/jax-ml/jax'))
hyper:bind({}, 'H', launch_app('Google Chat'))
hyper:bind({'shift'}, 'H', nil, dispatch_url('messenger.com'))
hyper:bind({}, 'I', launch_app('Messages'))
hyper:bind({}, 'J', dispatch_url('goto2.corp.google.com/jaxplorations'))
hyper:bind({'shift'}, 'J', nil, launch_app('Jetski'))
hyper:bind({}, 'L', dispatch_url('calendar.google.com'))
hyper:bind({'shift'}, 'L', nil, dispatch_url('calendar.google.com/calendar/u/1'))
hyper:bind({}, 'M', dispatch_url('mail.google.com'))
hyper:bind({'shift'}, 'M', nil, dispatch_url('mail.google.com/mail/u/1'))
hyper:bind({}, 'Q', dispatch_url('critique.corp.google.com'))
hyper:bind({}, 'R', launch_app('Reminders'))
hyper:bind({}, 'S', launch_app('Settings'))
hyper:bind({}, 'T', launch_app('WezTerm'))
hyper:bind({}, 'U', hs.reload)
hyper:bind({}, 'V', launch_app('Cider'))
hyper:bind({}, 'Y', hs.toggleConsole)
hyper:bind({}, 'UP', change_volume(5))
hyper:bind({}, 'DOWN', change_volume(-5))
hyper:bind({}, 'LEFT', toggle_mute)

hyper:bind({}, '[', function() moveWindowToPosition(screenPositions.left) end)
hyper:bind({'cmd'}, '[', function() move_window_to_prev_screen() end)
hyper:bind({}, ']', function() moveWindowToPosition(screenPositions.right) end)
hyper:bind({'cmd'}, ']', function() move_window_to_next_screen() end)
hyper:bind({}, '=', function() moveWindowToPosition(screenPositions.full) end)
hyper:bind({}, '\\', function() moveWindowToPosition(screenPositions.middle) end)

hs.hotkey.bind({'alt'}, 'f', function() hs.eventtap.keyStroke({'alt'}, 'right') end)
hs.hotkey.bind({'alt', 'shift'}, 'f', function() hs.eventtap.keyStroke({'alt', 'shift'}, 'right') end)
hs.hotkey.bind({'alt'}, 'b', function() hs.eventtap.keyStroke({'alt'}, 'left') end)
hs.hotkey.bind({'alt', 'shift'}, 'b', function() hs.eventtap.keyStroke({'alt', 'shift'}, 'left') end)
hs.hotkey.bind({'ctrl'}, 'down', function() hs.eventtap.keyStroke({'ctrl'}, 'n') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'down', function() hs.eventtap.keyStroke({'ctrl', 'shift'}, 'n') end)
hs.hotkey.bind({'ctrl'}, 'up', function() hs.eventtap.keyStroke({'ctrl'}, 'p') end)
hs.hotkey.bind({'ctrl', 'shift'}, 'up', function() hs.eventtap.keyStroke({'ctrl', 'shift'}, 'p') end)
hs.hotkey.bind({'ctrl'}, 'w', function() hs.eventtap.keyStroke({'ctrl'}, 'delete') end)
hs.hotkey.bind({'alt'}, 'd', function() hs.eventtap.keyStroke({'ctrl'}, 'forwarddelete') end)
