
--[[
	Scheduler in charge of managing and running events.
]]

local Scheduler		= {}

--- Contains all of the event objects
Scheduler.events	= {}

--- Polls the Scheduler for events waiting to fire.
function Scheduler:poll(timestamp)
	for i,v in ipairs(Scheduler.events) do
		if v:isReady(timestamp) then
			v:execute(timestamp)
			if v:isDone() then
				self:dequeue(v)
			end
		end
	end
end

--- Add an Event to the queue.
-- @param event The Event to queue.
function Scheduler:queue(event)
	table.insert(Scheduler.events, event)
end

--- Remove an event from the queue.
-- @param event	The even to deque.
function Scheduler:dequeue(event)
	table.removeValue(Scheduler.events, event)
	if event.onDone then event:onDone() end
end

--- Check if the Scheduler has Events waiting.
-- @return true if an Event is waiting.<br/> false otherwise.
function Scheduler:isWaiting()
	return #Scheduler.events > 0
end

--- Empties the Scheduler.
function Scheduler:clear()
	Scheduler.events = {}
end

_G.Scheduler = Scheduler

return Scheduler
