local Cloneable			= require("obj.Cloneable")
local baseObj			= Cloneable:clone()
--[[
	This is the base object most other objects will be cloned from so as many major functions should reside here as possable to reduce code in other modules
]]

function baseObj:initialize(pin)
	self.config = {}
	self:setID(pin)
	self:setName('object_'..pin)
	GPIO.setup(pin, GPIO.OUT,false)
end

function baseObj:setID(id)
	self.config.id = id
end

function baseObj:setName(name)
	self.config.name = name
end

function baseObj:getHTMLcontrol()
	return ([[<button onclick="myFunction('%s')">Test</button >]]):format('test')
end


function baseObj:getID()
	return self.config.id
end

function baseObj:getName()
	return self.config.name
end

function baseObj:readO()
	return GPIO.input(self:getID())
end

function baseObj:toggle()
	if self:readO() == true then
		self:off()
		return 'off'
	else
		self:on()
		return 'on'
	end
end

function baseObj:on()
	self:forceCheck()
	if self:readO() == false and not self.stayOff then
		GPIO.output(self:getID(), true)
		return true
	end
	return false
end

function baseObj:off()
	self:forceCheck()
	if self:readO() == true and not self.stayOn then
		GPIO.output(self:getID(), false)
		return true
	end
	return false
end

function baseObj:forceOn(f)
	self.stayOn = socket.gettime() + f
	return self:on()
end

function baseObj:forceOff(f)
	self.stayOff = socket.gettime() + f
	return self:off()
end

function baseObj:forceCheck()
	if self.stayOff and self.stayOff <= socket.gettime() then self.stayOff = nil end
	if self.stayOn and self.stayOn <= socket.gettime() then self.stayOn = nil end
end

function baseObj:test()
end

--- Stringifier for Cloneables.
function baseObj:toString()
	return string.format("[baseObj] %s %s",self:getID(),self:getName())
end

return baseObj
