local Cloneable			= require("obj.Common")
local Servo			= Cloneable:clone()
--[[
	Object used to drive 3 position Servo motors.
]]

Servo.updateCmd = "Request ServoMs"

Servo.positions = {'top','mid','bot'}

--- Constructor for instance-style clones.
function Servo:initialize(pin)
	if not _G.servoMotors then _G.servoMotors = {name='servoMotors'} table.insert(objects,servoMotors) objects["servoMotors"] = servoMotors end
	if not servoMotors[pin1..','..pin2..','..pin3..','..pin4] then
		self.config = {}
		self.position = 1
		self:setID(pin)
		self:setName('Servo_')
		table.insert(servoMotors,self)
		self:test()
	end
end

function Servo:getPosition()
	return (self.position and Servo.positions[self.position])
end

function Servo:setID(id)
	if self.config.id then servoMotors[self.config.id] = nil end
	self.config.id = id
	servoMotors[self.config.id] = self
end

function Servo:setName(name)
	if self.config.name then servoMotors[self.config.name] = nil end
	self.config.name = name
	servoMotors[self.config.name] = self
end

function Servo:getHTMLcontrol()
	return ([[<button onclick="myFunction('Som %s test')">Test</button >]]):format(self:getName())
end

function Servo:read()
	local r = "is " .. self:getDirection()
	return r
end


function Servo:off(up)
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

function Servo:setStep(step)
	if self.seq[step] then
		self.config.step = step
		return true
	end
	return false
end

function Servo:getStep()
	return self.config.step
end


function Servo:test()

end

--- Stringifier for Cloneables.
function Servo:toString()
	return string.format("[Servo] %s %s %s",self:getID(),self:getName(),self:getPosition())
end

return Servo
