local Cloneable			= require("obj.Common")
local Driver			= Cloneable:clone()
--[[
	Object used to drive 3 position Driver motors.
]]

Driver.updateCmd = "Request DriverMs"


--- Constructor for instance-style clones.
function Driver:initialize(pin)
	if not _G.driverMotors then _G.driverMotors = {name='driverMotors'} table.insert(objects,driverMotors) objects["driverMotors"] = driverMotors end
	if not driverMotors[pin1..','..pin2..','..pin3..','..pin4] then
		self.config = {}
		self.position = 1
		self:setID(pin)
		self:setName('Driver_')
		table.insert(driverMotors,self)
		self:test()
	end
end

function Driver:getDirectionA()
	return (self.movingA or 'stopped')
end


function Driver:getDirectionB()
	return (self.movingB or 'stopped')
end

function Driver:setID(id)
	if self.config.id then driverMotors[self.config.id] = nil end
	self.config.id = id
	driverMotors[self.config.id] = self
end

function Driver:setName(name)
	if self.config.name then driverMotors[self.config.name] = nil end
	self.config.name = name
	driverMotors[self.config.name] = self
end

function Driver:getHTMLcontrol()
	return ([[<button onclick="myFunction('Som %s test')">Test</button >]]):format(self:getName())
end

function Driver:read()
	local r = "is " .. self:getDirection()
	return r
end

function Driver:setupPins()
	for i,v in ipairs(self.pinsA) do
		v:set_direction('out')
	end
end

function Driver:setPins()
	for i,v in ipairs(self.pinsA) do
		v:write(self.seq[step][i])
	end
end

function Driver:stopA(up)
	--resetBoost(self)
	if self.movingA then

	end
	for i,v in ipairs(self.pinsA) do
		v:write(0)
	end
	if not up then self:updateMasters() end
	return true
end

function Driver:forwardA()
	if not self.movingA then

		return true
	end
	return false
end

function Driver:reverseA()
	if not self.movingA then

		return true
	end
	return false
end

function Driver:forwardB()
	if not self.movingB then

		return true
	end
	return false
end

function Driver:reverseB()
	if not self.movingB then

		return true
	end
	return false
end


function Driver:test()

end

--- Stringifier for Cloneables.
function Driver:toString()
	return string.format("[driver] %s %s %s",self:getID(),self:getName(),self:getPosition())
end

return Driver
