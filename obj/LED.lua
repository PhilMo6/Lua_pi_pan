local Cloneable			= require("obj.Common")
local LED			= Cloneable:clone()
--[[
	1 color LED module.
	Several functions are provided such as basic on, off, toggle, and blink functions and also force on and off which is located in the baseObj
]]

LED.location = 'LEDs'

function LED:setup(options)
	local pin = options.pin
	self.config.blinking = false
	self.config.pin = pin
	self.gpio = RPIO(pin)
	self.gpio:set_direction('out')
	self.gpio:write(0)
end

function LED:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s %s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('L %s on')">On</button >]]):format(name),
	([[<button onclick="myFunction('L %s off')">Off</button >]]):format(name),
	([[<button onclick="myFunction('L %s test')">Test</button >]]):format(name),
	([[<button onclick="myFunction('L %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end


function LED:on(client)
	self:forceCheck()
	if self:read() == 0 and not self.stayOff then
		self.gpio:write(1)
		if not self.blinking and self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:off(client)
	self:forceCheck()
	if self:read() == 1 and not self.stayOn then
		self.gpio:write(0)
		if not self.blinking and self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:blink(dir,count,client)
	if not self.blinking then
		local led = self
		led.config.blinking = true
		led.blinking = Event:new(function()
			led:toggle()
		end, dir or 1, true, count and count * 2 or 6)
		led.blinking.onDone = function()
			led:on() led.blinking = nil led.config.blinking = false led:off()
		end
		Scheduler:queue(led.blinking)
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:toggle(client)
	if self:read() == 0 then
		self:on(client)
		return 'on'
	else
		self:off(client)
		return 'off'
	end
end

function LED:read()
	return self.gpio:read()
end

function LED:forceOn(f)
	self.stayOn = socket.gettime() + f
	return self:on()
end

function LED:forceOff(f)
	self.stayOff = socket.gettime() + f
	return self:off()
end

function LED:forceCheck()
	if self.stayOff and self.stayOff <= socket.gettime() then self.stayOff = nil end
	if self.stayOn and self.stayOn <= socket.gettime() then self.stayOn = nil end
end

function LED:test()
	self.stayOff = nil
	self:blink(.5,10)
end

--- Stringifier for Cloneables.
function LED:toString()
	return string.format("[LED] %s %s %s",self:getID(),self:getName(),(self.blinking and "blinking" or self:read() == 1 and 'on' or 'off'))
end

return LED
