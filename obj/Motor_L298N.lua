local Cloneable			= require("obj.Common")
local Driver			= Cloneable:clone()
--[[
	Object used to drive 3 position Driver motors.
]]

Driver.updateCmd = "Request DriverMs"


--- Constructor for instance-style clones.
function Driver:initialize(pin1,pin2)
	if not _G.driverMotors then _G.driverMotors = {name='driverMotors'} table.insert(objects,driverMotors) objects["driverMotors"] = driverMotors end
	if not driverMotors[pin1..','..pin2] then
		self.config = {}
		self.position = 1
		self:setID(pin1..','..pin2)
		self:setName('Driver_')
		table.insert(driverMotors,self)
		self.pins = {RPIO(pin1),RPIO(pin2)}
		self:test()
	end
end

function Driver:getDirectionA()
	return (self.movingA or 'stopped')
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
	local r = self:getDirectionA() .. " " .. self:getDirectionB()
	return r
end

function Driver:setupPins()
	for i,v in ipairs(self.pins) do
		v:set_direction('out')
	end
end

function Driver:stop(up)
	--resetBoost(self)
	if self.moving then

	end
	for i,v in ipairs(self.pins) do
		v:write(0)
	end
	if not up then self:updateMasters() end
	return true
end

function Driver:forward()
	if not self.moving then

		return true
	end
	return false
end

function Driver:reverse()
	if not self.moving then

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
