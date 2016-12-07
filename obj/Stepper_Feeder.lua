local Cloneable			= require("obj.Common")
local Feeder			= Cloneable:clone()
--[[
	Object for feeding animals on a schedule.
]]

Feeder.location = 'feeders'

function Feeder:setup(options)
	local count,stepper,timing = options.count,options.stepper,options.timing
	self.config.count = count
	self.config.stepper = stepper
	self.config.timing = timing
	self.config.lastfeed = {}
	self.config.feeding=false
	self:startTimer()
end

function Feeder:startTimer()
	if self.config.timing and not self.timer then
		self.timer = Event:new(function()
			local hour,day = tonumber(os.date("%H")),tonumber(os.date("%d"))
			for i,v in ipairs(self.config.timing) do
				if hour == v and self.config.lastfeed[v] ~= day then
					self.config.lastfeed[v] = day
					self:feed()
				end
			end
		end, 60, true, 0)
		Scheduler:queue(self.timer)
	end
end

function Feeder:getHTMLcontrol()
	return ([[<button onclick="myFunction('Feeder %s test')">Test</button >]]):format(self:getName())
end

function Feeder:read()
	return (self.config.feeding == true and 'feeding' or 'standby')
end

function Feeder:feed()
	local stepper = stepperMotors and stepperMotors[self.config.stepper]
	if stepper and not self.feeding then
		local f = self
		f.config.feeding=true
		f.feeding = function(c)
			if not c then c = 0 end
			stepper:stepF(2000,function()
				if c <= f.config.count then
					c = c + 1
					stepper:stepB(500,function() f.feeding(c) end,true)
				else
					stepper:stepB(2000,function() stepper:off() f.feeding = nil f.config.feeding=false f:updateMasters() end)
				end
			end,(c ~= 0 and true or nil))
		end
		f.feeding()
		self:updateMasters()
	end
end

function Feeder:test(c)
	self:feed()
end

--- Stringifier for Cloneables.
function Feeder:toString()
	local last,next
	return string.format("[Feeder] %s %s",self:getID(),self:getName())
end

return Feeder
