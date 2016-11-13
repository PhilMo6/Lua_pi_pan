local Cloneable	= {}

--[[
	Base cloneable used to clone all other modules.
]]


--- Create a pure clone of a Cloneable.
function Cloneable.clone(parent)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable,
							__tostring=parent and parent.toString or Cloneable.toString
							}
	)
	return instance
end

--- Creates an instance-style clone of a Cloneable.
-- The clone is initialized, passing all arguments beyond the first to the clone's initialize() function.
function Cloneable.new(parent, ...)
	local c = Cloneable.clone(parent)
	c:initialize(...)
	return c
end

--- Constructor for instance-style clones.
function Cloneable:initialize(...)
end

--- Stringifier for Cloneables.
function Cloneable:toString()
	return "[cloneable]"
end

function Cloneable:getConfig()
	if self.config then
		return 'return '..table.savetoString(self.config)
	else
		return ""
	end
end

function Cloneable:setConfig(config)
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

function Cloneable:addMaster(master)
	if not self.masters then
		self.masters = {}
	end
	if not self.masters[master:getID()] then
		table.insert(self.masters,master)
		self.masters[master] = master
		self.masters[master:getID()] = master
	end
end

function Cloneable:removeMaster(master)
	if self.masters[master:getID()] then
		while table.removeValue(self.masters, master) do end
	end
	if self.masters == 0 then
		self.masters = nil
	end
end

function Cloneable:isMaster(master)
	if self.masters and self.masters[master] then
		return true
	end
	return false
end

function Cloneable:isNode(node)
	if self.node and self.node == node then
		return true
	end
	return false
end

function Cloneable:updateMasters()
	if self.masters and self.lastMasterUp ~= os.time() then
		local cmd = self.updateCmd and self.updateCmd .. " " .. self:getName() or nil
		if cmd then
			for i,v in ipairs(self.masters) do
				runningServer:parseCmd(cmd,v.client)
			end
		end
		self.lastMasterUp = os.time()
	end
end

return Cloneable
