local Cloneable			= require("obj.Common")
local Driver			= Cloneable:clone()
--[[
	Object used to drive motors connected with a L298N board.
]]

Driver.updateCmd = "Request DriverMs"


--- Constructor for instance-style clones.
function Driver:initialize(pin1,pin2,pmwR,pmwC)
	if not _G.motors then  require("source.wpiLuaWrap") _G.motors = {name='motors'} table.insert(objects,motors) objects["motors"] = motors end
	if not motors[pin1..','..pin2] then
		self.config = {pmwR=pmwR,pmwC=pmwC}
		self:setID(pin1..','..pin2)
		self:setName('Driver_'..pin1..','..pin2)
		table.insert(motors,self)
		self.pins = {RPIO(pin1),RPIO(pin2)}
		self:setupPins()
		self:test()
	end
end

function Driver:getDirection()
	return (self.moving or 'stopped')
end

function Driver:setID(id)
	if self.config.id then motors[self.config.id] = nil end
	self.config.id = id
	motors[self.config.id] = self
end

function Driver:setName(name)
	if self.config.name then motors[self.config.name] = nil end
	self.config.name = name
	motors[self.config.name] = self
end

function Driver:getHTMLcontrol()
	return ([[<button onclick="myFunction('Som %s test')">Test</button >]]):format(self:getName())
end

function Driver:read()
	local r = self:getDirectionA() .. " " .. self:getDirectionB()
	return r
end

function Driver:setupPins()
	for i,v in ipairs(self.pins) do
		v:set_direction('out')
	end
	if self.config.pmwR and self.config.pmwC then
		PWMsetup()
		self.config.pmw = true
		self:setSpeed(self.config.pmwR,self.config.pmwC)
	end
end

function Driver:setSpeed(pmwR,pmwC)
	if self.config.pmw then
		self.config.pmwR = pmwR or self.config.pmwR
		self.config.pmwC = pmwC or self.config.pmwC
		PWMset(self.config.pmwR or 10,self.config.pmwC or 2)
		return true
	end
	return false
end

function Driver:stop(up)
	--resetBoost(self)
	if self.moving then
		self.moving = nil
		for i,v in ipairs(self.pins) do
			v:write(0)
		end
		if not up then self:updateMasters() end
		return true
	end
	if self.pmw then PWMstop() end
end

function Driver:forward()
	if not self.moving or self.moving ~= 'forward' then
		self.moving = 'forward'
		self.pins[2]:write(0)
		self.pins[1]:write(1)
		return true
	end
	return false
end

function Driver:reverse()
	if not self.moving or self.moving ~= 'reverse' then
		self.moving = 'reverse'
		self.pins[1]:write(0)
		self.pins[2]:write(1)
		return true
	end
	return false
end

function Driver:test()
	motor:setSpeed(nil,2)
	self:forward()
	local motor = self
	Scheduler:queue(Event:new(function() motor:setSpeed(nil,5)
print('speed set 5')
		Scheduler:queue(Event:new(function() motor:setSpeed(nil,30)
print('speed set 30')
			Scheduler:queue(Event:new(function() motor:setSpeed(nil,60)
print('speed set 60')
				Scheduler:queue(Event:new(function() motor:setSpeed(nil,90)
print('speed set 90')
					Scheduler:queue(Event:new(function() motor:stop()
print('stopped\ntest done')
					end, 10, false))
				end, 10, false))

			end, 10, false))

		end, 10, false))

	end, 15, false))
end

--- Stringifier for Cloneables.
function Driver:toString()
	return string.format("[driver] %s %s %s",self:getID(),self:getName(),self:getDirection())
end

return Driver
