local Cloneable			= require("obj.baseObj")
local Buzzer			= Cloneable:clone()

--[[
	piezo buzzer! who doesen't love buzzers. whatever your need if you want to make some noise this is the module for you!
	working on making a better variety of noises.
]]

function Buzzer:initialize(pin)
	if not _G.buzzers then _G.buzzers = {name='buzzers'} _G.buzzerIDs = {} table.insert(objects,buzzers) objects["buzzers"] = buzzers end
	if not buzzers['Buzzer_'..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('Buzzer_'..pin)
		table.insert(buzzers,self)
		GPIO.setup(pin, GPIO.OUT,false)
	end
end

function Buzzer:getHTMLcontrol()
	return ('%s %s %s %s'):format(
	([[<button onclick="myFunction('B %s on')">On</button >]]):format(self:getName()),
	([[<button onclick="myFunction('B %s off')">Off</button >]]):format(self:getName()),
	([[<button onclick="myFunction('B %s stop')">Stop</button >]]):format(self:getName()),
	([[<button onclick="myFunction('B %s test')">Test</button >]]):format(self:getName())
	)
end

function Buzzer:setID(id)
	if self.config.id then buttonIDs[self.config.id] = nil end
	self.config.id = id
	buttonIDs[self.config.id] = self
end

function Buzzer:setName(name)
	if self.config.name then buzzers[self.config.name] = nil end
	self.config.name = name
	buzzers[self.config.name] = self
end

function Buzzer:buzz(leng)
	self:on()
	os.execute("sleep "..leng)
	self:off()
end

function Buzzer:beep(num,leng)
	if not self.beeping then
		local b = self
		b.beeping = Event:new(function()
			b:toggle()
		end, leng or .1, true, num and num * 2 or 6)
		b.beeping.onDone = function() b.beeping = nil b:off() end
		Scheduler:queue(b.beeping)
		return true
	end
	return false
end

function Buzzer:test()
	self.stayOff = nil
	self:beep()
end

--- Stringifier for Cloneables.
function Buzzer:toString()
	return string.format("[Buzzer] %s %s %s",self:getID(),self:getName(),(self:readO() == true and 'on' or 'off'))
end

return Buzzer
