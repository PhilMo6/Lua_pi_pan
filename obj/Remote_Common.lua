local Cloneable			= require("obj.Common")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by remote objects.
]]

function Common:initialize(id,name,config,node)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = config
		self:setID(id,true)
		self:setName(name ..'_'..node:getID(),false,true)
		self.sID = 'sID'..id..node:getID()
		table.insert(_G[self.location],self)
		node:addObject(self)
		if self.setup then self:setup(config) end
		self:setConfig(config,node,true)
	end
end

function Common:read()
	if not self:getLastRead() then
		return 'error'
	end
	return self:getLastRead()
end

function Common:setID(id,new)
	if self.config.id ~= id or new then
		if id and not objectIDs[id] then
			if objectIDs[self.config.id] and objectIDs[self.config.id] == self then objectIDs[self.config.id] = nil end
			if self.node then
				self.node.objectIDs[self.config.id] = nil
				self.node.objectIDs[id] = self
			end
			self.config.id = id
			objectIDs[id] = self
			self:updateMasters()
		elseif id then
			self.config.id = 000
			if self.node then self.node:send(([[obj %s newID]]):format(id)) end
		elseif self.config.id then
			if self.node then self.node:send(([[obj %s newID]]):format(self.config.id)) end
		end
	end
end

function Common:setName(name,user,new)
	if self.node then name = name ..'_'..self.node:getID() end
	if self.config.name ~= name or new then
		if self.config.name and self.config.name ~= name then
			if _G[self.location][self.config.name] and _G[self.location][self.config.name] == self then _G[self.location][self.config.name] = nil end
			if self.node then
				if user and user.node and user.node ~= self.node then self.node:send(([[obj %s rename %s]]):format(self:getID(),name)) end
				self.node.objects[self.location][self.config.name] = nil
				self.node.objects[self.location][name] = self
			end
			self:updateMasters()
		end
		self.config.name = name
		_G[self.location][self.config.name] = self
	end
end

function Common:setConfig(config,user,firstUpdate)
	if not config or not self.config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if firstUpdate or config[i] and config[i] ~= v then
			if i == 'name' and v ~= config[i]..'_'..self.node:getID() then
				self:setName(config[i],user)
			elseif i == 'id' then
				self:setID(config[i])
			elseif i == 'lastRead' then
				self:updateLastRead(config[i])
			else
				self.config[i] = config[i]
			end
			up = true
		end
	end
	if up then	self:updateMasters() end
end

return Common
