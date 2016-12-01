local Cloneable			= require("obj.Common")
local Relay			= Cloneable:clone()
--[[
	Object module for relays such as
	http://www.sainsmart.com/8-channel-dc-5v-relay-module-for-arduino-pic-arm-dsp-avr-msp430-ttl-logic.html
	This provides for reverse on off logic (on when pin set to low and off when set to high)
	Functions provided are on, off, toggle, forceOn and forceOff(in baseObj module)
]]

Relay.updateCmd = "Request RlUp"
Relay.location = 'relays'

function Relay:initialize(pin)
	if not _G.relays then _G.relays = {name='relays'} _G.relayIDs = {} table.insert(objects,relays) objects["relays"] = relays end
	if not relays['relay_'..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('relay_'..pin)
		table.insert(relays,self)
		self.gpio = RPIO(pin)
		self.gpio:set_direction('out')
		self.gpio:write(1)
	end
end

function Relay:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s %s <form id="%s"><input type="text" name='com'></form> ]]):format(
	([[<button onclick="myFunction('r %s on','%s')">On</button >]]):format(name,name),
	([[<button onclick="myFunction('r %s off','%s')">Off</button >]]):format(name,name),
	([[<button onclick="myFunction('r %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end


function Relay:setID(id)
	if self.config.id then relayIDs[self.config.id] = nil end
	self.config.id = id
	relayIDs[self.config.id] = self
end

function Relay:setName(name)
	if self.config.name then relays[self.config.name] = nil end
	self.config.name = name
	relays[self.config.name] = self
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

function Relay:off()
	self:forceCheck()
	if self:read() == 0 and not self.stayOn then
		self.gpio:write(1)
		self:updateMasters()
		return true
	end
	return false
end

function Relay:on()
	self:forceCheck()
	if self:read() == 1 and not self.stayOff then
		self.gpio:write(0)
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

function Relay:test()
end

function Relay:toString()
	return string.format("[relay] %s %s %s",self:getID(),self:getName(),(self:read() == 1 and 'off' or 'on'))
end

return Relay
