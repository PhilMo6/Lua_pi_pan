local Cloneable			= require("obj.Common")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by remote objects.
]]

function Common:initialize(id,config,node)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = config
		self:setID(id)
		self:setName(confg.name..'_'..node:getID())
		table.insert(_G[self.location],self)
		node:addObject(self)
		if self.setup then self:setup(config) end
	end
end

function Common:read()
	if not self.config.lastRead then
		return 'error'
	end
	return self:getLastRead()
end

function Common:setID(id)
	if self.config.id and self.config.id ~= id then
		_G[self.location][self.config.id] = nil
		objectIDs[id] = nil
		if self.node then
			self.node[self.location][self.config.id] = nil
			self.node[self.location][id] = self
			self.node.objectIDs[self.config.id] = nil
			self.node.objectIDs[id] = self
		end
	end
	self.config.id = id
	--_G[self.location][self.config.id] = self
	objectIDs[id] = self
end

function Common:setName(name)
	if self.config.name and self.config.name ~= name then
		_G[self.location][self.config.name] = nil
		if self.node then
			--self.node:send(([[S %s rename %s]]):format(self:getID(),name))
			self.node[self.location][self.config.name] = nil
			self.node[self.location][name] = self
		end
	end
	self.config.name = name
	_G[self.location][self.config.name] = self
end

return Common
