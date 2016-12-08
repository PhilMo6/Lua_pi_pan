local Cloneable			= require("obj.Common")
local Servo			= Cloneable:clone()
--[[
	Object used to drive 3 position Servo motors.
]]

Servo.location = 'servoMotors'

Servo.config = {}
Servo.config.positions = {'top','mid','bot'}
Servo.config.values = {top=100,mid=150,bot=200}
Servo.config.pmwR = 192
Servo.config.pmwC = 2000


function Servo:setup(options)
	require("source.wpiLuaWrap")
	local pin,pmwr,pmwc = options.pin,options.pmwr,options.pmwc
	self.config.pin = pin
	self.config.pmwR = pmwr or Servo.config.pmwR
	self.config.pmwC = pmwc or Servo.config.pmwC
	self:setupPins()
end

function Servo:getPosition()
	local positions = self.config.positions or Servo.config.positions
	return (self.position and positions[self.position])
end

function Servo:getHTMLcontrol()
	return ([[<button onclick="myFunction('Som %s test')">Test</button >]]):format(self:getName())
end

function Servo:read()
	local r = "is " .. self:getDirection()
	return r
end

function Servo:off(up)
	PWMstop()
	if not up then self:updateMasters() end
	return true
end

function Servo:setPosition(pos)
	local positions = self.config.positions or Servo.config.positions
	if positions[pos] then
		self.config.position = pos
		self:setPMW()
		return true
	end
	return false
end

function Servo:setupPins()
	PWMsetup()
	self.config.position = 1
	PWMCRset(self.pmwR,self.pmw)
end

function Servo:setPMW()
	local positions = self.config.positions or Servo.config.positions
	local values = self.config.values or Servo.config.values
	if positions[self.config.position] and values[positions[self.config.position]] then
		PWMset(values[positions[self.config.position]])
	end
end


function Servo:test()

end

--- Stringifier for Cloneables.
function Servo:toString()
	return string.format("[Servo] %s %s %s",self:getID(),self:getName(),self:getPosition())
end

return Servo
