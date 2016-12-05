local Cloneable			= require("obj.Common")
local Buzzer			= Cloneable:clone()

--[[
	piezo buzzer! who doesen't love buzzers. whatever your need if you want to make some noise this is the module for you!
	working on making a better variety of noises.
]]

Buzzer.location = 'buzzers'

function Buzzer:setup(options)
	local pin = options.pin
	self.gpio = RPIO(pin)
	self.gpio:set_direction('out')
	self.gpio:write(0)
	self.config.beeping = false
end

function Buzzer:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s %s %s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('B %s on')">On</button >]]):format(name),
	([[<button onclick="myFunction('B %s off')">Off</button >]]):format(name),
	([[<button onclick="myFunction('B %s stop')">Stop</button >]]):format(name),
	([[<button onclick="myFunction('B %s test')">Test</button >]]):format(name),
	([[<button onclick="myFunction('s %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end

function Buzzer:buzz(leng)
	self:on()
	os.execute("sleep "..leng)
	self:off()
end

function Buzzer:beep(num,leng)
	if not self.beeping then
		self.config.beeping = true
		local b = self
		b.beeping = Event:new(function()
			b:toggle()
		end, leng or .1, true, num and num * 2 or 6)
		b.beeping.onDone = function() b.beeping = nil self.config.beeping = false b:off() end
		Scheduler:queue(b.beeping)
		return true
	end
	return false
end

function Buzzer:read()
	return self.gpio:read()
end

function Buzzer:test()
	self.stayOff = nil
	self:beep()
end

function Buzzer:toggle()
	if self:read() == true then
		self:off()
		return 'off'
	else
		self:on()
		return 'on'
	end
end

function Buzzer:on()
	self:forceCheck()
	if self:read() == 0 and not self.stayOff then
		self.gpio:write(1)
		return true
	end
	return false
end

function Buzzer:off()
	self:forceCheck()
	if self:read() == 1 and not self.stayOn then
		self.gpio:write(0)
		return true
	end
	return false
end

function Buzzer:forceOn(f)
	self.stayOn = socket.gettime() + f
	return self:on()
end

function Buzzer:forceOff(f)
	self.stayOff = socket.gettime() + f
	return self:off()
end

function Buzzer:forceCheck()
	if self.stayOff and self.stayOff <= socket.gettime() then self.stayOff = nil end
	if self.stayOn and self.stayOn <= socket.gettime() then self.stayOn = nil end
end

--- Stringifier for Cloneables.
function Buzzer:toString()
	return string.format("[Buzzer] %s %s %s",self:getID(),self:getName(),(self:read() == 1 and 'on' or 'off'))
end

return Buzzer
