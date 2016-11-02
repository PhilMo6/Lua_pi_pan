local Cloneable			= require("obj.Cloneable")
local Stepper			= Cloneable:clone()
--[[
	Object used to drive stepper motors. Must be connect though a proper chip.
	This module needs some work... my stepper motor came to be broken
]]

--- Constructor for instance-style clones.
function Stepper:initialize(pin)
	self.config = {}
	self:setID(pin)
	self:setName('object_'..pin)
	GPIO.setup(pin, GPIO.OUT,false)
	self:step(1000)
end

function Stepper:setID(id)
	self.config.id = id
end

function Stepper:setName(name)
	self.config.name = name
end

function Stepper:getHTMLcontrol()
	return ([[<button onclick="myFunction('%s')">Test</button >]]):format('test')
end


function Stepper:getID()
	return self.config.id
end

function Stepper:getName()
	return self.config.name
end

function Stepper:readO()
	return GPIO.input(self:getID())
end

function Stepper:toggle()
	if self:readO() == true then
		GPIO.output(self:getID(), false)
		return 'off'
	else
		GPIO.output(self:getID(), true)
		return 'on'
	end
end

function Stepper:step(count,client)
	if client then if client.master then client = client.master elseif client.node then client = client.node end end
	if not self.stepping then
		local motor = self
		motor.stepping = Event:new(function()
			motor:on()
			sleep(.1)
			motor:off()
		end, .1, true, count or 60)
		motor.stepping.onDone = function()
			motor.stepping = nil motor:off()
		end
		Scheduler:queue(motor.stepping)
		if self.masters then
			for i,v in ipairs(self.masters) do
				--if v ~= client then runningServer:parseCmd("Request LEDUp "..self:getName(),v.client) end
			end
		end
		return true
	end
	return false
end

function Stepper:on()
	if self:readO() == false then
		GPIO.output(self:getID(), true)
		return true
	end
	return false
end

function Stepper:off()
	if self:readO() == true then
		GPIO.output(self:getID(), false)
		return true
	end
	return false
end

function Stepper:test()
	self:step(1000)
end

--- Stringifier for Cloneables.
function Stepper:toString()
	return string.format("[Stepper] %s %s",self:getID(),self:getName())
end

return Stepper
