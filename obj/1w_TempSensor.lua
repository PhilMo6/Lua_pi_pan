local Cloneable			= require("obj.Sensor")
local Sensor			= Cloneable:clone()

--[[
	This module is for 1 wire tempature sensors such as the DS18B20 and should be hooked up as is the provided link.
	https://learn.adafruit.com/adafruits-raspberry-pi-lesson-11-ds18b20-temperature-sensing/hardware
]]

Sensor.location = 'sensors'

function Sensor:setup(options)
	self.config.w_id = options.w_id
end

function Sensor:read()
	local tempC = 0
	local tempF = 0
	local sensor = io.open("/sys/bus/w1/devices/" .. self.config.w_id .. "/w1_slave","r")
	if sensor then
		local raw = sensor:read('*all')
		sensor:close()
		tempC = string.match(raw,'t=(%d+)')
		if tempC then
			tempC = tempC / 1000
			self:updateLastRead(tempC)
			tempF = tempC * 9 / 5  + 32
			return tempC,tempF
		else
			return tempC,tempF,"read error"
		end
	else
		return tempC,tempF,"connection error"
	end
	return tempC,tempF,'error'
end

function Sensor:getLastRead()
	return self.config.lastRead,(self.config.lastRead * 9 / 5  + 32)
end

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[1w_TempSensor] %s %s %sC %sF",self:getID(),self:getName(),t1,t2)
end

return Sensor
