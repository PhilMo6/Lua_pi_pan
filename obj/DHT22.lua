local Cloneable			= require("obj.Sensor")
local DHT22			= Cloneable:clone()

--[[
	DHT22 tempature and humidity sensor. connect as in the following
	https://learn.adafruit.com/dht-humidity-sensing-on-raspberry-pi-with-gdocs-logging/wiring
	NOT APPLICABLE TO DHT11. will work on that in the future.
]]

DHT22.updateCmd = "Request SenDHT22"

DHT22.location = 'DHTs'

function DHT22:initialize(pin)
	if not _G.DHTs then require("source.wpiLuaWrap") _G.DHTs = {name='DHTs'} table.insert(objects,DHTs) objects["DHTs"] = DHTs startPollSensorEvent() end
	if not DHTs['DHT22_' ..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('DHT22_' ..pin)
		self.lastTRead = 0
		self.lastHRead = 0
		table.insert(DHTs,self)
	end
end

function DHT22:setID(id)
	if self.config.id then DHTs[self.config.id] = nil end
	self.config.id = id
	DHTs[self.config.id] = self
end

function DHT22:setName(name)
	if self.config.name then DHTs[self.config.name] = nil end
	self.config.name = name
	DHTs[self.config.name] = self
end

function DHT22:read()
	local h,t = self:pollSensor()
	if h and h ~= 0.0 and h ~= 0 then
		h = math.round(h,2)
		t = math.round(t,2)
		local up = (self.lastHRead ~= h and true or self.lastTRead ~= t and true or nil)
		self.lastHRead = h
		self.lastTRead = t
		if self.masters and up then
			self:updateMasters()
		end
		self:updateLastRead(h..'|'..t)
		return h,t
	end
end

function DHT22:pollSensor()
	collectgarbage()
	collectgarbage('stop')
	local pin = self:getID()
	local sen = 22
	local hRead,tRead
	local count = 0
	while not hRead and count < 10 do
		hRead,tRead = readDHT(pin)
		count = count + 1
	end
	collectgarbage('restart')
	return hRead,tRead
end

function DHT22:getLastRead()
	return self.lastTRead,self.lastHRead
end

--- Stringifier for Cloneables.
function DHT22:toString()
	local h,t = self:getLastRead()
	local t2 = t * 9 / 5  + 32
	return string.format("[DHT22] %s %s %sC %s %s%%",self:getID(),self:getName(),t or 'nil',t2 or 'nil',h or 'nil')
end

return DHT22
