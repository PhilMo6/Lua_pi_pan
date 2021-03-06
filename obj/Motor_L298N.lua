local Cloneable			= require("obj.Common")
local Driver			= Cloneable:clone()
--[[
	Object used to drive motors connected with a L298N board.
]]

Driver.location = 'motors'
Driver.config = {}
Driver.config.speeds = {'crawl','slow','mid','fast','full'}
Driver.config.values = {crawl=100,slow=125,mid=150,fast=175,full=200}
Driver.config.speed = 1


function Driver:setup(options)
	local pin1,pin2,pmw = options[1],options[2],options.pmw
	if pwm then require("source.wpiLuaWrap") self.pwm = false end
	self.pins = {RPIO(pin1),RPIO(pin2)}
	self.config.pin1 = pin1
	self.config.pin2 = pin2
	self.config.moving = false
	self:setupPins()
end


function Driver:getDirection()
	return (self.config.moving or 'stopped')
end

function Driver:getHTMLcontrol()
	local id = self:getID()
	return ([[<button onclick="myFunction('obj %s test')">Test</button >]]):format(id)
end

function Driver:read()
	local r = self:getDirection()
	return r
end

function Driver:setupPins()
	for i,v in ipairs(self.pins) do
		v:set_direction('out')
	end
end

function Driver:startPwm()
	if self.pwm == false then
		self.pwm = true
		PWMsetup()
		PWMCRset(192,2000)
	end
end

function Driver:setSpeed(speed)
	if self.pwm and speed and speed ~= self.config.speed then
		self.config.speed = speed
		local speeds = self.config.speeds or Driver.config.speeds
		local values = self.config.values or Driver.config.values
		if speeds[self.config.speed] and values[speeds[self.config.speed]] then
			PWMset(values[speeds[self.config.speed]])
			return true
		end
	end
	return false
end

function Driver:stop(up)
	--resetBoost(self)
	if self.config.moving then
		self.config.moving = false
		for i,v in ipairs(self.pins) do
			v:write(0)
		end
		if not up then self:updateMasters() end
		return true
	end
	if self.pwn then PWMstop() self.pwn = false end
end

function Driver:forward()
	if self.pwm == false then self:startPwm() end
	if not self.config.moving or self.config.moving ~= 'forward' then
		self.config.moving = 'forward'
		self.pins[2]:write(0)
		self.pins[1]:write(1)
		self:updateMasters()
		return true
	end
	return false
end

function Driver:reverse()
	if self.pwm == false then self:startPwm() end
	if not self.config.moving or self.config.moving ~= 'reverse' then
		self.config.moving = 'reverse'
		self.pins[1]:write(0)
		self.pins[2]:write(1)
		self:updateMasters()
		return true
	end
	return false
end

function Driver:test()
	self:forward()
	self:setSpeed(1)
	local motor = self
	Scheduler:queue(Event:new(function() motor:setSpeed(2)
print('speed set 2')
		Scheduler:queue(Event:new(function() motor:setSpeed(3)
print('speed set 3')
			Scheduler:queue(Event:new(function() motor:setSpeed(4)
print('speed set 4')
				Scheduler:queue(Event:new(function() motor:stop()
print('stopped\ntest done')
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
