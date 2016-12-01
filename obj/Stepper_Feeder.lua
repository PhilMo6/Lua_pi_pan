local Cloneable			= require("obj.Common")
local Feeder			= Cloneable:clone()
--[[
	Object for feeding animals on a schedule.
]]

Feeder.updateCmd = "Request Feeder"
Feeder.location = 'feeders'

--- Constructor for instance-style clones.
function Feeder:initialize(id,count,stepper,timing)
	if not _G.feeder then _G.feeders = {name='feeders'} table.insert(objects,feeders) objects["feeders"] = feeders end
	if not feeders[id] then
		self.config = {count=count,stepper=stepper,timing=timing,lastfeed={},feeding=false}
		self:setID(id)
		self:setName('Feeder_'..id)
		table.insert(feeders,self)
		self:startTimer()
	end
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

function Feeder:setID(id)
	if self.config.id then feeders[self.config.id] = nil end
	self.config.id = id
	feeders[self.config.id] = self
end

function Feeder:setName(name)
	if self.config.name then feeders[self.config.name] = nil end
	self.config.name = name
	feeders[self.config.name] = self
end

function Feeder:getHTMLcontrol()
	return ([[<button onclick="myFunction('Feeder %s test')">Test</button >]]):format(self:getName())
end

function Feeder:read()
	return (self.feeding == true and 'feeding' or 'standby')
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
					stepper:stepB(500,function() f.feeding(c) end)
				else
					stepper:stepB(2000,function() stepper:off() f.feeding = nil f.config.feeding=false end)
				end
			end)
		end
		f.feeding()
	end
end

function Feeder:test(c)
	self:feed()
end

--- Stringifier for Cloneables.
function Feeder:toString()
	return string.format("[Feeder] %s %s",self:getID(),self:getName())
end

return Feeder
