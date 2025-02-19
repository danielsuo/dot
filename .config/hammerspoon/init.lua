require("hs.ipc")

hs.loadSpoon("URLDispatcher")
hs.loadSpoon("ShiftIt")

hyper = { "cmd", "alt", "ctrl", "shift" }

spoon.URLDispatcher:start()
spoon.ShiftIt:bindHotkeys({
	left = { hyper, "[" },
	right = { hyper, "]" },
	maximum = { hyper, "=" },
})
hs.window.animationDuration = 0

local launch_app = function(app)
	return function()
		hs.application.launchOrFocus(app)
	end
end

local dispatch_url = function(url)
	return function()
		spoon.URLDispatcher:dispatchURL("", "", "", "https://" .. url, -1)
	end
end
function change_volume(diff)
	return function()
		local current = hs.audiodevice.defaultOutputDevice():volume()
		local new = math.min(100, math.max(0, math.floor(current + diff)))
		if new > 0 then
			hs.audiodevice.defaultOutputDevice():setMuted(false)
		end
		hs.alert.closeAll(0.0)
		hs.alert.show("Volume " .. new .. "%", {}, 0.5)
		hs.audiodevice.defaultOutputDevice():setVolume(new)
	end
end
local toggle_mute = function()
	mute = not hs.audiodevice.defaultOutputDevice():muted()
	hs.audiodevice.defaultOutputDevice():setMuted(mute)
	hs.alert.closeAll(0.0)
	if mute then
		hs.alert.show("Muted")
	else
		hs.alert.show("Unmuted")
	end
end

hs.hotkey.bind(hyper, "B", dispatch_url("b.corp.google.com/home"))
hs.hotkey.bind(hyper, "C", launch_app("Google Chrome"))
hs.hotkey.bind(hyper, "E", dispatch_url("goto2.corp.google.com/sknow"))
hs.hotkey.bind(hyper, "F", launch_app("Finder"))
hs.hotkey.bind(hyper, "G", dispatch_url("github.com"))
hs.hotkey.bind(hyper, "H", launch_app("Google Chat"))
hs.hotkey.bind(hyper, "I", launch_app("Messages"))
hs.hotkey.bind(hyper, "J", dispatch_url("goto2.corp.google.com/jaxplorations"))
hs.hotkey.bind(hyper, "L", dispatch_url("calendar.google.com"))
hs.hotkey.bind(hyper, "M", dispatch_url("mail.google.com"))
hs.hotkey.bind(hyper, "Q", dispatch_url("critique.corp.google.com"))
hs.hotkey.bind(hyper, "R", hs.reload)
hs.hotkey.bind(hyper, "S", launch_app("Settings"))
hs.hotkey.bind(hyper, "T", launch_app("WezTerm"))
hs.hotkey.bind(hyper, "V", launch_app("Cider"))
hs.hotkey.bind(hyper, "Y", hs.toggleConsole)
hs.hotkey.bind(hyper, "UP", change_volume(5))
hs.hotkey.bind(hyper, "DOWN", change_volume(-5))
hs.hotkey.bind(hyper, "LEFT", toggle_mute)
