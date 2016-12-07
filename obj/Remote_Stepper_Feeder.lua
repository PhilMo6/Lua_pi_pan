local Cloneable			= require("obj.Common")
local origin			= require("obj.Stepper_Feeder")
local Feeder			= Cloneable:clone()
--[[
	Object for feeding animals on a schedule.
]]

Feeder.location = origin.location
Feeder.getHTMLcontrol = origin.getHTMLcontrol

function Feeder:test(c)

end

--- Stringifier for Cloneables.
function Feeder:toString()
	local last,next
	return string.format("[Feeder] %s %s",self:getID(),self:getName())
end

return Feeder
