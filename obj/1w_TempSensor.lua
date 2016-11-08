local Cloneable			= require("obj.Sensor")
local Sensor			= Cloneable:clone()

--[[
	This module is for 1 wire tempature sensors such as the DS18B20 and should be hooked up as is the provided link.
	https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/hardware
]]

Sensor.updateCmd = "Request SenTemp"

function Sensor:initialize(id)
	if not _G.sensors then _G.sensors = {name='sensors'} table.insert(objects,sensors) objects["sensors"] = sensors startPollSensorEvent() end
	if not sensors[id] then
		self.config = {}
		self:setID(id)
		self:setName(id)
		self.lastRead = 0
		self.lastUp = os.time()
		table.insert(sensors,self)
	end
end

function Sensor:updateLastRead(v)
	self.lastRead = v
end

function Sensor:read()
	local tempC = 0
	local tempF = 0
	local sensor = io.open("/sys/bus/w1/devices/" .. self:getID() .. "/w1_slave","r")
	local lastread = self.lastRead
	local lastup = self.lastUp
	if sensor then
		local raw = sensor:read('*all')
		sensor:close()
		tempC = string.match(raw,'t=(%d+)')
		if tempC then
			self.lastUp = os.time()
			tempC = tempC / 1000
			self:updateLastRead(tempC)
			tempF = tempC * 9 / 5  + 32
			if self.masters and lastread ~= self.lastRead and lastup ~= self.lastUp then
				self:updateMasters()
			end
			return tempC,tempF,(tempF <= 32 and "read error low" or tempF >= 180 and "read error high" or nil)
		else
			return tempC,tempF,"read error"
		end
	else
		return tempC,tempF,"connection error"
	end
	return tempC,tempF,'error'
end

function Sensor:getLastRead()
	return self.lastRead,(self.lastRead * 9 / 5  + 32)
end

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[1w_TempSensor] %s %s %sC %sF",self:getID(),self:getName(),t1,t2)
end

return Sensor
