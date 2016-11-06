local Cloneable			= require("obj.Sensor")
local DHT22			= Cloneable:clone()
--[[
	Remote object for DHT22 sensors attached to nodes.
	Node will update the remote sensors last read as the sensors tempature/humidity changes.
]]

function DHT22:initialize(id,name,node)
	if not _G.DHT22s then _G.DHT22s = {name='DHT22s'} table.insert(objects,DHT22s) objects["DHT22s"] = DHT22s end
	if not DHT22s[name..'_'..node:getID()] then
		self.config = {}
		self:setID(id)
		self:setName(name..'_'..node:getID())
		self.lastTRead = 0
		self.lastHRead = 0
		table.insert(DHT22s,self)
		node:addDHT22(self)
	end
end

function DHT22:removeSensor()
	DHT22s[self:getName()] = nil
	DHT22s[self:getID()] = nil
	while table.removeValue(DHT22s, self) do end
	if self.node then local node=self.node self.node=nil node:removeSensor(self) end
end

function DHT22:setID(id)
	self.config.id = id
end

function DHT22:setName(name)
	if self.config.name then DHT22s[self.config.name] = nil end
	self.config.name = name
	DHT22s[self.config.name] = self
end

function DHT22:updateLastRead(hv,tv)
	if hv then
		local up = (self.lastHRead ~= h and true or self.lastTRead ~= t and true or nil)
		self.lastHRead = h
		self.lastTRead = t
		if self.masters and up then
			self:updateMasters()
		end
	end
end

function DHT22:read()
	return self:getLastRead()
end

function DHT22:pollSensor()
	return self:getLastRead()
end

function DHT22:getLastRead()
	return self.lastHRead,self.lastTRead
end

--- Stringifier for Cloneables.
function DHT22:toString()
	local t,h = self:getLastRead()
	return string.format("[Remote_DHT22] %s %s %sC %s%%",self:getID(),self:getName(),t or 'nil',h or 'nil')
end

return DHT22
