local Cloneable			= require("obj.Common")
local Driver			= Cloneable:clone()
--[[
	Object used to drive motors connected with a L298N board.
]]

Driver.updateCmd = "Request DriverMs"
Driver.config = {}
Driver.config.speeds = {'crawl','slow','mid','fast','full'}
Driver.config.values = {crawl=100,slow=125,mid=150,fast=175,full=200}
Driver.config.speed = 1

--- Constructor for instance-style clones.
function Driver:initialize(pin1,pin2,pwm)
	if not _G.motors then require("source.wpiLuaWrap") _G.motors = {name='motors'} table.insert(objects,motors) objects["motors"] = motors end
	if not motors[pin1..','..pin2] then
		self.config = {}
		if pwm then self.pwm = false end
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
	if self.moving then
		self.moving = nil
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
	if not self.moving or self.moving ~= 'forward' then
		self.moving = 'forward'
		self.pins[2]:write(0)
		self.pins[1]:write(1)
		return true
	end
	return false
end

function Driver:reverse()
	if self.pwm == false then self:startPwm() end
	if not self.moving or self.moving ~= 'reverse' then
		self.moving = 'reverse'
		self.pins[1]:write(0)
		self.pins[2]:write(1)
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
