local Cloneable			= require("obj.baseObj")
local Relay			= Cloneable:clone()
--[[
	Object module for relays such as
	http://www.sainsmart.com/8-channel-dc-5v-relay-module-for-arduino-pic-arm-dsp-avr-msp430-ttl-logic.html
	This provides for reverse on off logic (on when pin set to low and off when set to high)
	Functions provided are on, off, toggle, forceOn and forceOff(in baseObj module)
]]

Relay.updateCmd = "Request RlUp"

function Relay:initialize(pin)
	if not _G.relays then _G.relays = {name='relays'} _G.relayIDs = {} table.insert(objects,relays) objects["relays"] = relays end
	if not relays['relay_'..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('relay_'..pin)
		table.insert(relays,self)
		GPIO.setup(pin, GPIO.OUT,true)
	end
end

function Relay:getHTMLcontrol()
	return ([[%s %s <form id="%s"> for <input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('r %s on','%s')">On</button >]]):format(self:getName(),self:getName()),
	([[<button onclick="myFunction('r %s off','%s')">Off</button >]]):format(self:getName(),self:getName())
	,self:getName()
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

function Relay:toggle(client)
	if self:readO() == true then
		self:on(client)
		return 'on'
	else
		self:off(client)
		return 'off'
	end
end

function Relay:off(client)
	self:forceCheck()
	if self:readO() == false and not self.stayOn then
		GPIO.output(self:getID(), true)
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function Relay:on(client)
	self:forceCheck()
	if self:readO() == true and not self.stayOff then
		GPIO.output(self:getID(), false)
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function Relay:toString()
	return string.format("[relay] %s %s %s",self:getID(),self:getName(),(self:readO() == true and 'off' or 'on'))
end

return Relay
