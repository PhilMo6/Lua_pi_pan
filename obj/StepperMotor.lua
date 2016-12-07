local Cloneable			= require("obj.Common")
local Stepper			= Cloneable:clone()
--[[
	Object used to drive stepper motors. Must be connect though a driver board.
]]

Stepper.location = 'stepperMotors'

Stepper.seq = {{1,0,0,1},
       {1,0,0,0},
       {1,1,0,0},
       {0,1,0,0},
       {0,1,1,0},
       {0,0,1,0},
       {0,0,1,1},
       {0,0,0,1}}

function Stepper:setup(options)
	local pin1,pin2,pin3,pin4 = options.pin1,options.pin2,options.pin3,options.pin4
	self.config.pin1 = pin1
	self.config.pin2 = pin2
	self.config.pin3 = pin3
	self.config.pin4 = pin4
	self.step = 1
	table.insert(stepperMotors,self)
	self.pins = {RPIO(pin1),RPIO(pin2),RPIO(pin3),RPIO(pin4)}
	self:setupPins()
	self:off()
end


function Stepper:getDirection()
	return (self.stepping and self.stepping.direction or 'stopped')
end

function Stepper:getHTMLcontrol()
	return ([[<button onclick="myFunction('Stm %s test')">Test</button >]]):format(self:getName())
end

function Stepper:read()
	local r = "is " .. self:getDirection()
	return r
end

function Stepper:setupPins()
	local step = self:getStep()
	for i,v in ipairs(self.pins) do
		v:set_direction('out')
		v:write(self.seq[step][i])
	end
end

function Stepper:setPins()
	local step = self:getStep()
	for i,v in ipairs(self.pins) do
		v:write(self.seq[step][i])
	end
end

function Stepper:off(up)
	resetBoost(self)
	if self.stepping then
		Scheduler:dequeue(self.stepping)
		self.stepping = nil
		self.config.stepping = false
	end
	for i,v in ipairs(self.pins) do
		v:write(0)
	end
	if not up then self:updateMasters() end
	return true
end

function Stepper:setStep(step)
	if self.seq[step] then
		self.config.step = step
		return true
	end
	return false
end

function Stepper:getStep()
	return self.config.step
end

function Stepper:setSpeed(v)
	self.config.speed = v
	if self.stepping then
		self.stepping.repeatInterval = v
	end
	return true
end

function Stepper:getSpeed()
	return self.config.speed
end

function Stepper:stepF(count,ondone,up)
	if not self.stepping then
		boostFrequency(self,3)
		local motor = self
		motor.config.stepping = true
		motor.stepping = Event:new(function()
			local step = motor:getStep() + 1
			if motor.seq[step] then
				motor:setStep(step)
				motor:setPins()
			else
				motor:setStep(1)
				motor:setPins()
			end
		end, motor:getSpeed(), true, count or 60)
		motor.stepping.onDone = function()
			motor.stepping = nil
			self.config.stepping = false
			motor:off(up)
			if ondone then ondone() end
		end
		motor.stepping.direction = "forward"
		Scheduler:queue(motor.stepping)
		if not up then self:updateMasters() end
		return true
	end
	return false
end

function Stepper:stepB(count,ondone,up)
	if not self.stepping then
		boostFrequency(self,3)
		local motor = self
		motor.config.stepping = true
		motor.stepping = Event:new(function()
			local step = motor:getStep() - 1
			if motor.seq[step] then
				motor:setStep(step)
				motor:setPins()
			else
				motor:setStep(#self.seq)
				motor:setPins()
			end
		end, motor:getSpeed(), true, count or 60)
		motor.stepping.onDone = function()
			motor.stepping = nil
			self.config.stepping = false
			motor:off(up)
			if ondone then ondone() end
		end
		motor.stepping.direction = "backward"
		Scheduler:queue(motor.stepping)
		if not up then self:updateMasters() end
		return true
	end
	return false
end

function Stepper:test(c)
if not c then c = 0 end
print('stepper test',c)
	self:stepF(2000,function()
		if c <= 20 then
			c = c + 1
			self:stepB(500,function() self:test(c) end)
		else
			self:stepB(2000,function() self:off() end)
		end
	end)
end

--- Stringifier for Cloneables.
function Stepper:toString()
	return string.format("[Stepper] %s %s %s",self:getID(),self:getName(),self:getDirection())
end

return Stepper
