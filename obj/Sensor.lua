local Cloneable			= require("obj.Common")
local sensor			= Cloneable:clone()

--[[
	Base object for sensors.
]]



function sensor:initialize(id)
	if not _G.sensors then _G.sensors = {name='sensors'} table.insert(objects,sensors) objects["sensors"] = sensors end
	if not sensors[id] then
		self.config = {}
		self:setID(id)
		self:setName(id)
		self.lastRead = nil
		table.insert(sensors,self)
	end
end

function sensor:setID(id)
	if self.config.id then sensors[self.config.id] = nil end
	self.config.id = id
	sensors[self.config.id] = self
end

function sensor:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('s %s r')">Read</button >]]):format(name,name),
	([[<button onclick="myFunction('s %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end

function sensor:setName(name)
	if self.config.name then sensors[self.config.name] = nil end
	self.config.name = name
	sensors[self.config.name] = self
end

function sensor:getLastRead()
	return self.lastRead
end

function sensor:read()
	local reading = nil
	return reading
end

--- Stringifier for Cloneables.
function sensor:toString()
	return string.format("[Sensor] %s %s",self:getID(),self:getName())
end

return sensor
