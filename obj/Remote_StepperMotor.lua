local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.StepperMotor")
local Stepper			= Cloneable:clone()
--[[
	Object used to drive stepper motors. Must be connect though a driver board.
]]

Stepper.location = origin.location
Stepper.getHTMLcontrol = origin.getHTMLcontrol

function Stepper:getDirection()
	return (self.stepping or 'stopped')
end

function Stepper:off()
	if self.node then
		self.node:send(([[Stm %s off]]):format(self:getID()))
	end
	if not up then updateMasters() end
	return true
end

function Stepper:setStep(step)
end

function Stepper:setSpeed(v)
	if self.node then
		self.node:send(([[Stm %s ss %s]]):format(self:getID(),v))
	end
	return true
end

function Stepper:stepF(count)
	if not self.stepping then
		if self.node then
			self.node:send(([[Stm %s f %s]]):format(self:getID(),count))
		end
		return true
	end
	return false
end

function Stepper:stepB(count)
	if not self.stepping then
		if self.node then
			self.node:send(([[Stm %s b %s]]):format(self:getID(),count))
		end
		return true
	end
	return false
end

function Stepper:test()
	if self.node then
		self.node:send(([[Stm %s test]]):format(self:getID()))
	end
end


--- Stringifier for Cloneables.
function Stepper:toString()
	return string.format("[Remote_Stepper] %s %s %s",self:getID(),self:getName(),self:getDirection())
end

return Stepper
