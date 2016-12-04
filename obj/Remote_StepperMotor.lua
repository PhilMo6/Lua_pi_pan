local Cloneable			= require("obj.Remote_Common")
local Stepper			= Cloneable:clone()
--[[
	Object used to drive stepper motors. Must be connect though a driver board.
]]

Stepper.location = 'stepperMotors'

--- Constructor for instance-style clones.
function Stepper:initialize(id,name,node)
	if not _G.stepperMotors then _G.stepperMotors = {name='stepperMotors'} table.insert(objects,stepperMotors) objects["stepperMotors"] = stepperMotors end
	if not stepperMotors[name..'_'..node:getID()] then
		self.config = {speed=.001}
		self.step = 1
		self:setID(id)
		self:setName(name..'_'..node:getID())
		node:addStepperMotors(self)
		table.insert(stepperMotors,self)
	end
end

function Stepper:removeSelf()
	stepperMotors[self:getName()] = nil
	while table.removeValue(stepperMotors, self) do end
	if self.node then local node=self.node self.node=nil node:removeStepperMotor(self) end
end

function Stepper:getDirection()
	return (self.stepping or 'stopped')
end

function Stepper:setID(id)
	if self.config.id then
		if self.node then
			self.node.stepperMotors[self.config.id] = nil
			self.node.stepperMotors[id] = self
		end
	end
	self.config.id = id
end

function Stepper:setName(name)
	if self.config.name then
		stepperMotors[self.config.name] = nil
		if self.node then
			self.node:send(([[Stm %s rename %s]]):format(self:getID(),name))
			self.node.stepperMotors[self.config.name] = nil
			self.node.stepperMotors[name] = self
		end
	end
	self.config.name = name
	stepperMotors[self.config.name] = self
end

function Stepper:setupPins()
end

function Stepper:setPins()
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
