local Cloneable			= require("obj.LightSensor")
local Sensor			= Cloneable:clone()
--[[
	Remote object for light sensors attached to nodes.
	Node will update the remote sensors last read as the sensors light level changes.
]]

function Sensor:initialize(id,name,node)
	if not _G.lightsensors then _G.lightsensors = {name='lightsensors'} table.insert(objects,lightsensors) objects["lightsensors"] = lightsensors end
	if not lightsensors[name..'_'..node:getID()] then
		self.config = {}
		self:setID(id)
		self:setName(name..'_'..node:getID())
		self.lastRead = nil
		node:addLSensor(self)
		lightsensors[self:getName()] = self
		table.insert(lightsensors,self)
	end
end

function Sensor:removeSensor()
	lightsensors[self:getName()] = nil
	while table.removeValue(lightsensors, self) do	end
	if self.node then local node=self.node self.node=nil node:removeLSensor(self) end
end

function Sensor:setID(id)
	if self.config.id then
		if self.node then
			self.node.lightsensors[self.config.id] = nil
			self.node.lightsensors[id] = self
		end
	end
	self.config.id = id
end

function Sensor:setName(name)
	if self.config.name then
		lightsensors[self.config.name] = nil
		if self.node then
			self.node:send(([[S %s rename %s]]):format(self:getID(),name))
			self.node.lightsensors[self.config.name] = nil
			self.node.lightsensors[name] = self
		end
	end
	self.config.name = name
	lightsensors[self.config.name] = self
end

function Sensor:read()
	if not self.lastRead then
		self.node:send('Request SenLight')
		return nil,nil,'error'
	end
	return self:getLastRead()
end

function Sensor:updateLastRead(v)
	local lastread = self.lastRead
	self.lastRead = v
	if self.masters and lastread ~= self.lastRead then
		self:updateMasters()
	end
end

function Sensor:getLastRead()
	return self.lastRead,self:lightLevel(self.lastRead),self.lastError
end

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[Remote_LightSensor] %s %s %s %s %s",self.node and self.node:getID() or 'none',self:getID(),self:getName(),t1 or "",t2 or "")
end

return Sensor
