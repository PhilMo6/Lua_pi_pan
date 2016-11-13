local Cloneable			= require("obj.Sensor")
local DHT22			= Cloneable:clone()

--[[
	DHT22 tempature and humidity sensor. Connect as in the following
	https://learn.adafruit.com/dht-humidity-sensing-on-raspberry-pi-with-gdocs-logging/wiring
	NOT APPLICABLE TO DHT11. will work on that in the future.
]]

DHT22.updateCmd = "Request SenDHT22"

function DHT22:initialize(pin)
	if not _G.DHT22s then require("source.readDHT") _G.DHT22s = {name='DHT22s'} table.insert(objects,DHT22s) objects["DHT22s"] = DHT22s startPollSensorEvent() end
	if not DHT22s['DHT22_' ..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('DHT22_' ..pin)
		self.lastTRead = 0
		self.lastHRead = 0
		table.insert(DHT22s,self)
	end
end

function DHT22:setID(id)
	if self.config.id then DHT22s[self.config.id] = nil end
	self.config.id = id
	DHT22s[self.config.id] = self
end

function DHT22:setName(name)
	if self.config.name then DHT22s[self.config.name] = nil end
	self.config.name = name
	DHT22s[self.config.name] = self
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
	local t2
	if t then t2 = = t * 9 / 5  + 32 end
	return string.format("[DHT22] %s %s %sC %sF %s%%",self:getID(),self:getName(),t or 'nil',t2 or 'nil',h or 'nil')
end

return DHT22
