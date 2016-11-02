local Cloneable			= require("obj.Cloneable")
local Event				= Cloneable.clone()

--[[
	Base object used for all events. Allows for up to .01 with a decent level of accuracy.
	Events are blocking and if being used for proccesser heavy applications you should consider
	applying basic multithreading ideology and break your function at differnt steps to allow for other events to run.
]]


-- event settings
Event.destination		= 0 -- a timestamp for some point in the future
Event.didRun			= false -- did this event run already?

-- repeating events
Event.shouldRepeat		= false -- should it repeat?
Event.currentRepeat		= 0 -- which cycle we're on
Event.repeatMax			= 0 -- how many times to repeat (0 is infinite)
Event.repeatInterval	= 0 -- what offset from previous execution to repeat


function Event:initialize(fun, repeatInterval, shouldRepeat, repeatMax)
	self.run			= fun or self.run
	self.shouldRepeat	= shouldRepeat or self.shouldRepeat
	self.repeatMax		= repeatMax or self.repeatMax
	self.repeatInterval	= repeatInterval or self.repeatInterval
	self.destination	= self.repeatInterval + socket.gettime()
end

--- Check if the event is ready to fire.
function Event:isReady(timestamp)
	if self.ready ~= nil then
		-- is this event "done"?
		if self:isDone() then
			return false
		end
		-- have we reached our destination?
		if timestamp >= self.destination then
			return true
		end
		return false
	else
		self.destination = timestamp + self.repeatInterval
		self.ready = true
		return false
	end
end

--- Check if this event will fire anymore.
function Event:isDone()
	if self.ready == false or self:hasRun() and not self:willRepeat() then
		return true
	end
	return false
end

--- Check if this event has had its first firing.
function Event:hasRun()
	return self.didRun
end

--- Will this event repeat (anymore)? Takes into consideration whether or not we have reached our repeat maximum, so it will return false if we have reached it.
function Event:willRepeat()
	return self.shouldRepeat == true and (self.currentRepeat < self.repeatMax or self.repeatMax == nil or self.repeatMax == 0)
end

--- The intended access point for running the event.
function Event:execute(timestamp)
	-- if it has not run yet, indicate it has
	if not self:hasRun() then
		self.didRun			= true
	else-- if it has run, indicate this is a repeat
		self.currentRepeat	= self.currentRepeat + 1
	end
	self:run(timestamp)
	-- prepare for the next repeation, if necessary
	if self:willRepeat() then
		self.destination = timestamp + self.repeatInterval
	end
end

function Event:toString()
	return "[event]"
end

return Event
