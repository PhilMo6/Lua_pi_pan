local Cloneable			= require("obj.Cloneable")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by most other objects.
]]

function Common:initialize(id,options)
	if not _G[self.location] then _G[self.location] = {name=self.location} table.insert(objects,_G[self.location]) objects[self.location] = _G[self.location] end
	if not _G[self.location][id] then
		self.config = {lastRead=false}
		self:setID(id)
		self:setName('sensor_'..id)
		table.insert(sensors,self)
		if self.setup then self:setup(options) end
	end
end

function Common:removeSelf()
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
	if self.config.id and self.config.id ~= id then
		_G[self.location][self.config.id] = nil
		if self.node then
			self.node[self.location][self.config.id] = nil
			self.node[self.location][id] = self
		end
	end
	self.config.id = id
	_G[self.location][self.config.id] = self
end

function Common:setName(name)
	if self.config.name and self.config.name ~= name then
		_G[self.location][self.config.name] = nil
		if self.node then
			self.node:send(([[S %s rename %s]]):format(self:getID(),name))
			self.node[self.location][self.config.name] = nil
			self.node[self.location][name] = self
		end
	end
	self.config.name = name
	_G[self.location][self.config.name] = self
end

function Common:toString()
	return "[Common]"
end

function Common:getConfig()
	if self.config then
		return 'return '..table.savetoString(self.config)
	else
		return ""
	end
end

function Common:getLastRead()
	return self.config.lastRead
end

function Common:updateLastRead(v)
	local lastread = self.config.lastRead
	self.config.lastRead = v
	if self.masters and lastread ~= self.config.lastRead then
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
				self:setLastRead(config[i])
			else
				self.config[i] = config[i]
			end
			up = true
		end
	end
	if up then	self:updateMasters() end
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
	if self.masters == 0 then
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
	if self.masters then
		local cmd = self.location and "Request objectUpdate "..self.location.." "..self:getName() or nil --self.updateCmd and self.updateCmd .. " " .. self:getName() or nil
		if cmd then
			for i,v in ipairs(self.masters) do
				runningServer:parseCmd(cmd,v.client)
			end
		end
	end
end

return Common
