local Cloneable			= require("obj.Common")
local sensor			= Cloneable:clone()

--[[
	Base object for sensors.
]]

function sensor:initialize(id)
	if not _G.sensors then _G.sensors = {name='sensors'} table.insert(objects,sensors) objects["sensors"] = sensors end
	if not sensors[id] then
		self.config = {lastRead=false}
		self:setID(id)
		self:setName('sensor_'..id)
		table.insert(sensors,self)
	end
end

function sensor:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('s %s r')">Read</button >]]):format(name,name),
	([[<button onclick="myFunction('s %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end

return sensor
