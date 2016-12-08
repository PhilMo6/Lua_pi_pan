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
	local id = self:getID()
	return ([[%s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('obj %s r')">Read</button >]]):format(id,id),
	([[<button onclick="myFunction('obj %s re','%s')">Rename</button >]]):format(id,id),
	id
	)
end

return sensor
