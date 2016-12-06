local Cloneable			= require("obj.Common")
local sensor			= Cloneable:clone()

--[[
	Base object for sensors.
]]

function sensor:setup(options)
	startPollSensorEvent()
	self:read()
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
