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
	self.config.timing = timing or {}
	self.config.lastfeed = {}
	self.config.feeding=false
	self:startTimer()
end

function Feeder:startTimer()
	if self.config.timing and #self.config.timing > 0 and not self.timer then
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

function Feeder:toString()
	local next
	if self.config.timing and #self.config.timing > 0 then
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
