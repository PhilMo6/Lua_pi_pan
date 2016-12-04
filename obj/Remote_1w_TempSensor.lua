local Cloneable			= require("obj.1w_TempSensor")
local Sensor			= Cloneable:clone()
--[[
	Remote object for 1 wire sensors attached to nodes.
	Node will update the remote sensors last read as the sensors tempature changes.
]]

Sensor.location = 'sensors'

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[Remote_1w_TempSensor] %s %s %s %sC %sF",self.node and self.node:getID() or 'none',self:getID(),self:getName(),t1,t2)
end

return Sensor
