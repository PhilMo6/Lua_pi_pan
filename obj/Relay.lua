local Cloneable			= require("obj.Common")
local Relay			= Cloneable:clone()
--[[
	Object module for relays such as
	http://www.sainsmart.com/8-channel-dc-5v-relay-module-for-arduino-pic-arm-dsp-avr-msp430-ttl-logic.html
	This provides for reverse on off logic (on when pin set to low and off when set to high)
	Functions provided are on, off, toggle, forceOn and forceOff(in baseObj module)
]]

Relay.location = 'relays'

function Relay:setup(options)
	local pin = options.pin
	self.config.pin = pin
	self.config.reverselogic = options.reverselogic or nil
	self.gpio = RPIO(pin)
	self.gpio:set_direction('out')
	self.gpio:write(0)
	if self.config.reverselogic then
		self.on = Relay.off
		self.off = Relay.on
	end
end

function Relay:getHTMLcontrol()
	local id = self:getID()
	return ([[%s %s %s %s <form id="%s"><input type="text" name='com'></form> ]]):format(
	([[<button onclick="myFunction('obj %s on','%s')">On</button >]]):format(id,id),
	([[<button onclick="myFunction('obj %s off','%s')">Off</button >]]):format(id,id),
	([[<button onclick="myFunction('r %s timer','%s')">Set timer</button >]]):format(self:getName(),id),
	([[<button onclick="myFunction('obj %s re','%s')">Rename</button >]]):format(id,id),
	id
	)
end

function Relay:toggle()
	if self:read() == 1 then
		self:on()
		return 'on'
	else
		self:off()
		return 'off'
	end
end

--returns a 1 or 0 based off if logic is reversed for this relay(the relay is turned on by a low pin)
--this is used for telling if the relay is on or off
function Relay:getLogic()
	if self.config.reverselogic then
		return self:read() == 0 and 1 or 0
	else
		return self.gpio:read()
	end
end

function Relay:off()
	self:forceCheck()
	if self:getLogic() == 1 and not self.stayOn then
		self.gpio:write(0)
		self:updateMasters()
		return true
	end
	return false
end

function Relay:on()
	self:forceCheck()
	if self:getLogic() == 0 and not self.stayOff then
		self.gpio:write(1)
		self:updateMasters()
		return true
	end
	return false
end

function Relay:read()
	self:updateLastRead(self.gpio:read())
	return self.config.lastRead
end

function Relay:forceOn(f)
	self.stayOn = socket.gettime() + f
	return self:on()
end

function Relay:forceOff(f)
	self.stayOff = socket.gettime() + f
	return self:off()
end

function Relay:forceCheck()
	if self.stayOff and self.stayOff <= socket.gettime() then self.stayOff = nil end
	if self.stayOn and self.stayOn <= socket.gettime() then self.stayOn = nil end
end

function Relay:timerOn(duration)
	self:on()
	Scheduler:queue(Event:new(function()
		self:off()
	end, duration, false))
end

function Relay:test()
end

function Relay:toString()
	return string.format("[relay] %s %s %s",self:getID(),self:getName(),(self:getLogic() == 0 and 'off' or 'on'))
end

return Relay
