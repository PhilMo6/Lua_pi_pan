local Cloneable			= require("obj.Cloneable")
local Stepper			= Cloneable:clone()
--[[
	Object used to drive stepper motors. Must be connect though a driver board.
]]

Stepper.updateCmd = "Request StepMs"

Stepper.seq = {{1,0,0,1},
       {1,0,0,0},
       {1,1,0,0},
       {0,1,0,0},
       {0,1,1,0},
       {0,0,1,0},
       {0,0,1,1},
       {0,0,0,1}}

--- Constructor for instance-style clones.
function Stepper:initialize(pin1,pin2,pin3,pin4)
	if not _G.stepperMotors then _G.stepperMotors = {name='stepperMotors'} table.insert(objects,stepperMotors) objects["stepperMotors"] = stepperMotors end
	if not stepperMotors[pin1..','..pin2..','..pin3..','..pin4] then
		self.config = {speed=.001,step=1}
		self.step = 1
		self:setID(pin1..','..pin2..','..pin3..','..pin4)
		self:setName('stepper_'..pin1..','..pin2..','..pin3..','..pin4)
		table.insert(stepperMotors,self)
		self.pins = {RPIO(pin1),RPIO(pin2),RPIO(pin3),RPIO(pin4)}
		self:setupPins()
		self:test()
	end
end

function Stepper:getDirection()
	return (self.stepping and self.stepping.direction or 'stopped')
end

function Stepper:setID(id)
	if self.config.id then stepperMotors[self.config.id] = nil end
	self.config.id = id
	stepperMotors[self.config.id] = self
end

function Stepper:setName(name)
	if self.config.name then stepperMotors[self.config.name] = nil end
	self.config.name = name
	stepperMotors[self.config.name] = self
end

function Stepper:getHTMLcontrol()
	return ([[<button onclick="myFunction('Stm %s test')">Test</button >]]):format(self:getName())
end


function Stepper:getID()
	return self.config.id
end

function Stepper:getName()
	return self.config.name
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

function Stepper:stepF(count,ondone)
	if not self.stepping then
		boostFrequency(self,3)
		local motor = self
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
			motor:off()
			if ondone then ondone() end
		end
		motor.stepping.direction = "forward"
		Scheduler:queue(motor.stepping)
		self:updateMasters()
		return true
	end
	return false
end

function Stepper:stepB(count,ondone)
	if not self.stepping then
		boostFrequency(self,3)
		local motor = self
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
			motor:off()
			if ondone then ondone() end
		end
		motor.stepping.direction = "backward"
		Scheduler:queue(motor.stepping)
		self:updateMasters()
		return true
	end
	return false
end

function Stepper:test()
	self:stepF(10000,function() self:stepB(10000) end)
end

--- Stringifier for Cloneables.
function Stepper:toString()
	return string.format("[Stepper] %s %s %s",self:getID(),self:getName(),self:getDirection())
end

return Stepper
