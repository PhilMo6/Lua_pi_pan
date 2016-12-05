local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.LED")
local LED			= Cloneable:clone()
--[[
	Remote object for 1 color LEDs attached to nodes.
	Node will update the LED whenever change is detected.
]]

LED.location = origin.location
LED.toggle = origin.toggle
LED.getHTMLcontrol = origin.getHTMLcontrol

function LED:updateLastRead(v)
	local lastread = self.lastRead
	self.lastRead = v
	if not self.config.blinking and lastread ~= self.lastRead then
		self:updateMasters()
	end
end

function LED:getHTMLcontrol()
	return ('%s %s %s'):format(
	([[<button onclick="myFunction('L %s on')">On</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s off')">Off</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s test')">Test</button >]]):format(self:getName())
	)
end


function LED:blink(dir,count,client)
	if not self.config.blinking then
		self.node:send(([[LED %s blink %s %s]]):format(self:getID(),dir or "",count or ""))
		if self.masters then
			self:updateMasters()
		end
	end
	return false
end

function LED:test()
	if self.node then self.node:send(([[LED %s test]]):format(self:getID())) end
end

function LED:off()
	if not self.config.blinking and self:read() == 1 then
		self.node:send(([[LED %s off]]):format(self:getID()))
		self:updateMasters()
		return true
	end
	return false
end

function LED:on()
	if not self.config.blinking and self:read() == 0 then
		self.node:send(([[LED %s on]]):format(self:getID()))
		self:updateMasters()
		return true
	end
	return false
end

--- Stringifier for Cloneables.
function LED:toString()
	return string.format("[Remote_LED] %s %s %s",self:getID(),self:getName(),(self.blinking and "blinking" or self:read() == 1 and 'on' or 'off'))
end

return LED
