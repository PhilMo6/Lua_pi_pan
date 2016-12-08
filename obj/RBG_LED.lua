local Cloneable			= require("obj.LED")
local LED			= Cloneable:clone()
--[[
	RBG LED module.
	Several functions are provided such as basic on, off, toggle, blink, cycle, and random color functions and also force on and off which is located in the baseObj
]]
LED.colors = {
{0,0,1},
{0,1,1},
{0,1,0},
{1,1,0},
{1,0,0},
{1,1,1},
{0,1,0},
{0,1,1},
{0,0,1},
{0,1,1},
{0,1,0},
{1,1,0}
}

function LED:setup(options)
	local pinR,pinB,pinG = options.pinR,options.pinB,options.pinG
	self.config = {
		blinking=false,
		cycling=false,
		random=false,
		pinRed = pinR,
		pinBlue = pinB,
		pinGreen = pinG,
		r = 1,
		b = 1,
		g = 1
	}
	self.gpioR = RPIO(pinR)
	self.gpioR:set_direction('out')
	self.gpioR:write(0)
	self.gpioB = RPIO(pinB)
	self.gpioB:set_direction('out')
	self.gpioB:write(0)
	self.gpioG = RPIO(pinG)
	self.gpioG:set_direction('out')
	self.gpioG:write(0)
end


function LED:getHTMLcontrol()
	local id = self:getID()
	return ([[%s %s %s %s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('obj %s on')">On</button >]]):format(id),
	([[<button onclick="myFunction('obj %s off')">Off</button >]]):format(id),
	([[<button onclick="myFunction('obj %s test')">Test1</button >]]):format(id),
	([[<button onclick="myFunction('obj %s test 1')">Test2</button >]]):format(id),
	([[<button onclick="myFunction('obj %s re','%s')">Rename</button >]]):format(id,id),
	id
	)
end

function LED:read()
	return self:getRedPin(),self:getBluePin(),self:getGreenPin()
end

function LED:setRedPin(s)
	if s then self:setRed(s) end
	self.gpioR:write(self:getRed())
end
function LED:getRedPin()
	return self.gpioR:read()
end
function LED:setBluePin(s)
	if s then self:setBlue(s) end
	self.gpioB:write(self:getBlue())
end
function LED:getBluePin()
	return self.gpioB:read()
end
function LED:setGreenPin(s)
	if s then self:setGreen(s) end
	self.gpioG:write(self:getGreen())
end
function LED:getGreenPin()
	return self.gpioG:read()
end

function LED:setRed(s)
	if s ~= 0 and s ~= 1 then s = 0 end
	self.config.r = tonumber(s)
end
function LED:getRed()
	return self.config.r
end
function LED:setBlue(s)
	if s ~= 0 and s ~= 1 then s = 0 end
	self.config.b = tonumber(s)
end
function LED:getBlue()
	return self.config.b
end
function LED:setGreen(s)
	if s ~= 0 and s ~= 1 then s = 0 end
	self.config.g = tonumber(s)
end
function LED:getGreen()
	return self.config.g
end

function LED:on(r,b,g,client)
	self:forceCheck()
	self:setRedPin(r)
	self:setBluePin(b)
	self:setGreenPin(g)
	if not self.blinking and not self.cycling and self.masters then
		self:updateMasters()
	end
	return true
end

function LED:off()

	if self.blinking then
		Scheduler:dequeue(self.blinking)
		self.blinking = nil
		self.config.blinking = false
	end
	if self.cycling then
		Scheduler:dequeue(self.cycling)
		self.cycling = nil
		self.config.cycling = false
	end

	self.gpioR:write(0)
	self.gpioB:write(0)
	self.gpioG:write(0)
	if not self.blinking then
		self:updateMasters()
	end
	return true

end

function LED:blink(dir,count,client)
	if not self.blinking then
		local led = self
		led.blinking = Event:new(function()
			led:toggle()
		end, dir or 1, true, count and count * 2 or 6)
		led.blinking.onDone = function()
			led.blinking = nil led:off()
		end
		Scheduler:queue(led.blinking)
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:toggle(client)
	local r,b,g = self:read()
	if r == 1 or b == 1 or g == 1 then
		self:off(client)
		return 'off'
	else
		self:on(client)
		return 'on'
	end
end

function LED:cycle(client)
	if self.blinking then
		Scheduler:dequeue(self.blinking)
		self.blinking = nil
		self.config.blinking = false
	end
	if self.cycling then
		Scheduler:dequeue(self.cycling)
		self.cycling = nil
		self.config.cycling = false
	end
	if not self.cycling then
		local led = self
		led.config.cycling = true
		local color = 0
		led.cycling = Event:new(function()

			if led.colors[color + 1] then color = color + 1 else color = 1 end

			led:on(led.colors[color][1],led.colors[color][2],led.colors[color][3])
		end, .2, true, 60*5)
		led.cycling.onDone = function()
			led.cycling = nil led:off()
		end
		Scheduler:queue(led.cycling)
		if self.masters then
			self:updateMasters()
		end
		return true
	end
end

function LED:randomColor(client)
	if self.blinking then
		Scheduler:dequeue(self.blinking)
		self.blinking = nil
		self.config.blinking = false
	end
	if self.cycling then
		Scheduler:dequeue(self.cycling)
		self.cycling = nil
		self.config.cycling = false
	end

	local led = self
	led.config.cycling = true
	led.cycling = Event:new(function()
	local r,b,g = math.random(0,1),math.random(0,1),math.random(0,1)
	while r == 0 and b == 0 and g == 0 do
		r,b,g = math.random(0,1),math.random(0,1),math.random(0,1)
	end
		led:on(r,b,g)
	end, .2, true, 60*5)
	led.cycling.onDone = function()
		led.cycling = nil led:off()
	end
	Scheduler:queue(led.cycling)
	if self.masters then
		self:updateMasters()
	end
	return true
end

function LED:test(i)
	if tonumber(i) == 1 then
		self:cycle()
	else
		self:randomColor()
	end
end

--- Stringifier for Cloneables.
function LED:toString()
	local r,b,g = self:read()
	return string.format("[RBG_LED] %s %s %s,%s,%s",self:getID(),self:getName(),(r == 1 and 'on' or 'off'),(b == 1 and 'on' or 'off'),(g == 1 and 'on' or 'off'))
end

return LED
