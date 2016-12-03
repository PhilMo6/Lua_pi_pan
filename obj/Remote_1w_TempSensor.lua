local Cloneable			= require("obj.1w_TempSensor")
local Sensor			= Cloneable:clone()
--[[
	Remote object for 1 wire sensors attached to nodes.
	Node will update the remote sensors last read as the sensors tempature changes.
]]

function Sensor:initialize(id,name,config,node)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = config
		self:setID(id)
		self:setName(name..'_'..node:getID())
		node:addObject(self)
		table.insert(sensors,self)
	end
end

function Sensor:setID(id)
	if self.config.id and self.config.id ~= id then
		sensors[self.config.id] = nil
		if self.node then
			self.node.sensors[self.config.id] = nil
			self.node.sensors[id] = self
		end
	end
	self.config.id = id
	sensors[self.config.id] = self
end

function Sensor:setName(name)
	if self.config.name and self.config.name ~= name then
		sensors[self.config.name] = nil
		if self.node then
			self.node:send(([[S %s rename %s]]):format(self:getID(),name))
			self.node.sensors[self.config.name] = nil
			self.node.sensors[name] = self
		end
	end
	self.config.name = name
	sensors[self.config.name] = self
end

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[Remote_1w_TempSensor] %s %s %s %sC %sF",self.node and self.node:getID() or 'none',self:getID(),self:getName(),t1,t2)
end

return Sensor
