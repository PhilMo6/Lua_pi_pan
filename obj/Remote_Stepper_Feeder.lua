local Cloneable			= require("obj.Common")
local origin			= require("obj.Stepper_Feeder")
local Feeder			= Cloneable:clone()
--[[
	Object for feeding animals on an hourly schedule.
]]

Feeder.location = origin.location
Feeder.getHTMLcontrol = origin.getHTMLcontrol

function Feeder:test(c)
	self.node:send(([[Obj %s test]]):format(self:getID()))
end

function Feeder:toString()
	local next
	if self.config.timing and #self.config.timing > 0 and
		local hour,day = tonumber(os.date("%H")),tonumber(os.date("%d"))
		for i,v in ipairs(self.config.timing) do
			if (next == nil or next < v) and v < hour and self.config.lastfeed[v] and self.config.lastfeed[v] ~= day then
				next = v
			end
		end
	end
	return string.format("[Feeder] %s %s %s Next feed at:%s",self:getID(),self:getName(),self.config.feeding and 'feeding' or 'standby',next or 'tommorow')
end

return Feeder
