local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.Relay")
local Relay			= Cloneable:clone()
--[[
	Remote object for relay attached to nodes.
	Node will update the relay as changes are detected.
]]

Relay.location = origin.location
Relay.toggle = origin.toggle
Relay.getHTMLcontrol = origin.getHTMLcontrol

function Relay:off(client)
	if self:read() == 0 and not self.stayOn then
		self.node:send(([[R %s off]]):format(self:getID()))
		return true
	end
	return false
end

function Relay:on(client)
	if self:read() == 1 and not self.stayOff then
		self.node:send(([[R %s on]]):format(self:getID()))
		return true
	end
	return false
end

function Relay:toString()
	return string.format("[Remote_relay] %s %s %s",self:getID(),self:getName(),(self:read() == 1 and 'off' or 'on'))
end

return Relay
