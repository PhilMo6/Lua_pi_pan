local Cloneable			= require("obj.Common")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by remote objects.
]]

function Common:initialize(id,name,config,node)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = config
		self:setID(id)
		self:setName(name..'_'..node:getID())
		self.sID = 'sID'..id..node:getID()
		table.insert(_G[self.location],self)
		node:addObject(self)
		if self.setup then self:setup(config) end
	end
end

function Common:read()
	if not self:getLastRead() then
		return 'error'
	end
	return self:getLastRead()
end

function Common:setID(id)
	if self.config.id and self.config.id ~= id then
		_G[self.location][self.config.id] = nil
		objectIDs[id] = nil
		if self.node then
			self.node.objects[self.location][self.config.id] = nil
			self.node.objects[self.location][id] = self
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
			self.node.objects[self.location][self.config.name] = nil
			self.node.objects[self.location][name] = self
		end
	end
	self.config.name = name
	_G[self.location][self.config.name] = self
end

function Common:setConfig(config)
	if not config or not self.config then return end
	--local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'name' and v ~= config[i]..'_'..self.node:getID() then
				self:setName(config[i])
			elseif i == 'id' then
				self:setID(config[i])
			elseif i == 'lastRead' then
				self:updateLastRead(config[i])
			else
				self.config[i] = config[i]
			end
			--up = true
		end
	end
	--if up then	self:updateMasters() end
end

return Common
