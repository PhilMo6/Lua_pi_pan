local Cloneable			= require("obj.Cloneable")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by most other objects.
]]

function Common:initialize(id,options)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = {lastRead=false}
		self:setID()
		self:setName(options and options.name or self.location..'_'..id)
		self.sID = 'sID'..id
		table.insert(_G[self.location],self)
		if self.setup then self:setup(options) end
	end
end

function Common:removeSelf()
	if objectIDs[self:getID()] == self then objectIDs[self:getID()] = nil end
	if _G[self.location] then
		_G[self.location][self:getName()] = nil
		while table.removeValue(_G[self.location], self) do end
		if self.node then local node=self.node self.node=nil node:removeObject(self) end
		if self.masters then for i,v in ipairs(self.masters) do self:removeMaster(v) end end
	end
end

function Common:getID()
	return (self.config and self.config.id)
end

function Common:getName()
	return (self.config and self.config.name)
end

function Common:setID(id)
	if not id then id = getNewID(12) end
	if not objectIDs[id] then
		if self.config.id and self.config.id ~= id then
			--_G[self.location][self.config.id] = nil
			objectIDs[id] = nil
		end
		self.config.id = id
		--_G[self.location][self.config.id] = self
		objectIDs[id] = self
		self:updateMasters()
		return true
	end
end

function Common:setName(name)
	if self.config.name and self.config.name ~= name then
		if _G[self.location][self.config.name] and _G[self.location][self.config.name] == self then _G[self.location][self.config.name] = nil end
		self:updateMasters()
	end
	self.config.name = name
	_G[self.location][self.config.name] = self
end

function Common:toString()
	return "[Common]"
end

function Common:getConfig(firstUp)
	if self.config then
		return table.savetoString(self.config)
	else
		return "nil"
	end
end

function Common:getLastRead()
	return self.config.lastRead
end

function Common:updateLastRead(v)
	local lastread = self.config.lastRead
	self.config.lastRead = v
	if lastread ~= self.config.lastRead then
		self:updateMasters()
	end
end

function Common:setConfig(config)
	if not config or not self.config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'name' then
				self:setName(config[i])
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

function Common:getStatus()
	local status = ""
	for i,v in pairs(self.config) do
		local ty = type(v)
		status = string.format([[%s
%s:%s]],status,i,(ty == 'string' and v or ty == 'number' and v or ty == 'boolean' and (v == true and 'true' or 'false') or ty == 'table' and v:toString()))
	end
	return string.format("%s%s",self:toString(),status)
end

function Common:addMaster(master)
	if not self.masters then
		self.masters = {}
	end
	if not self.masters[master:getID()] then
		table.insert(self.masters,master)
		self.masters[master:getID()] = master
	end
end

function Common:removeMaster(master)
	if self.masters[master:getID()] then
		while table.removeValue(self.masters, master) do end
	end
	master:removeObject(self)
	if #self.masters == 0 then
		self.masters = nil
	end
end

function Common:isMaster(master)
	if self.masters and self.masters[master:getID()] then
		return true
	end
	return false
end

function Common:isNode(node)
	if self.node and self.node == node then
		return true
	end
	return false
end

function Common:updateMasters()
	if self.masters and not self.masterUpdate then
		local obj = self
		obj.masterUpdate = Event:new(function()
			if obj.masters then
				local cmd = "Request objectUpdate "..obj:getID() --self.updateCmd and self.updateCmd .. " " .. self:getName() or nil
				for i,v in ipairs(obj.masters) do
					runningServer:parseCmd(cmd,v.client)
				end
			end
			obj.masterUpdate = nil
		end, 2, false)
		Scheduler:queue(obj.masterUpdate)
	end
end

return Common
