local Cloneable			= require("obj.Cloneable")
local Common			= Cloneable:clone()
--[[
	Common object to hold functions used by most other objects.
]]

function Common:getID()
	return (self.config and self.config.id)
end

function Common:getName()
	return (self.config and self.config.name)
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

function Common:setConfig(config)
	if not config or not self.config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'name' then
				self:setName(config[i])
			elseif i == 'id' then
				self:setID(config[i])
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
		self.masters[master] = master
		self.masters[master:getID()] = master
	end
end

function Common:removeMaster(master)
	if self.masters[master:getID()] then
		while table.removeValue(self.masters, master) do end
	end
	if self.masters == 0 then
		self.masters = nil
	end
end

function Common:isMaster(master)
	if self.masters and self.masters[master] then
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
		local cmd = self.updateCmd and self.updateCmd .. " " .. self:getName() or nil
		if cmd then
			for i,v in ipairs(self.masters) do
				runningServer:parseCmd(cmd,v.client)
			end
		end
	end
end

return Common
