local Cloneable			= require("obj.Cloneable")
local LED			= Cloneable:clone()
--[[
	1 color LED module.
	Several functions are provided such as basic on, off, toggle, and blink functions and also force on and off which is located in the baseObj
]]

LED.updateCmd = "Request LEDUp"

function LED:initialize(pin)
	if not _G.LEDs then _G.LEDs = {name='LEDs'} _G.LEDIDs = {} table.insert(objects,LEDs) objects["LEDs"] = LEDs end
	if not LEDs['LED_'..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('LED_'..pin)
		table.insert(LEDs,self)
		self.gpio = RPIO(pin)
		self.gpio:set_direction('out')
		self.gpio:write(0)
	end
end

function LED:getHTMLcontrol()
	return ('%s %s %s'):format(
	([[<button onclick="myFunction('L %s on')">On</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s off')">Off</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s test')">Test</button >]]):format(self:getName())
	)
end

function LED:setID(id)
	if self.config.id then LEDIDs[self.config.id] = nil end
	self.config.id = id
	LEDIDs[self.config.id] = self
end

function LED:setName(name)
	if self.config.name then LEDs[self.config.name] = nil end
	self.config.name = name
	LEDs[self.config.name] = self
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
		led.blinking = Event:new(function()
			led:toggle()
		end, dir or 1, true, count and count * 2 or 6)
		led.blinking.onDone = function()
			led:on() led.blinking = nil led:off()
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

function LED:getID()
	return self.config.id
end

function LED:getName()
	return self.config.name
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
