local Cloneable			= require("obj.baseObj")
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
		GPIO.setup(pin, GPIO.OUT,false)
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
	if self:readO() == false and not self.stayOff then
		GPIO.output(self:getID(), true)
		if not self.blinking and self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:off(client)
	self:forceCheck()
	if self:readO() == true and not self.stayOn then
		GPIO.output(self:getID(), false)
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
	if self:readO() == false then
		self:on(client)
		return 'on'
	else
		self:off(client)
		return 'off'
	end
end

function LED:test()
	self.stayOff = nil
	self:blink(.5,10)
end

--- Stringifier for Cloneables.
function LED:toString()
	return string.format("[LED] %s %s %s",self:getID(),self:getName(),(self.blinking and "blinking" or self:readO() == true and 'on' or 'off'))
end

return LED
