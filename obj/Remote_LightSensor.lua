local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.LightSensor")
local Sensor			= Cloneable:clone()
--[[
	Remote object for light sensors attached to nodes.
	Node will update the remote sensors last read as the sensors light level changes.
]]

Sensor.location = origin.location
Sensor.getHTMLcontrol = origin.getHTMLcontrol
Sensor.lightLevel = origin.lightLevel --use function from non remote object to save memory
Sensor.getLastRead = origin.getLastRead --use function from non remote object to save memory


--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[Remote_LightSensor] %s %s %s %s %s",self.node and self.node:getID() or 'none',self:getID(),self:getName(),t1 or "",t2 or "")
end

return Sensor
