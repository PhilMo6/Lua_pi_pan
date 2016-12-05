local Cloneable			= require("obj.Sensor")
local Sensor			= Cloneable:clone()

--[[
	This light sensor module is for a LDR or photocell circuit as found here
	https://learn.adafruit.com/basic-resistor-sensor-reading-on-raspberry-pi/basic-photocell-reading
	the code is based off adafruits code in the provided link with the exception of a few things.
	First I found by taking multiple readings and choosing the median reading out of those I got much more consistent results.
	Second I relised that different rpi's cycle at differnt speeds and as such provided inconsistent readings.
	After a little testing I found by tracking the time instead of cycles I got much more consistent readings between rpi's.
	Thirdly I connnect several photocells together and they tend to give slightly more stable results but it also narrows the over all range of lighting that it will readings
	The light sensor will calibration to keep up speed when in low light.
	!This is a high processer use object so use with care!
]]

Sensor.updateCmd = "Request SenLight"
Sensor.calibration = 1--must be as least 1
Sensor.accuracy = 7--must be as least 2
Sensor.maxRead = 4000--highest starting value for read
--[[32000 is sufficent to cover the full range of possable readings but takes a long time to do a full set of readings.
If you dont need to detect low light conditions and want faster readings you can restrict maxRead and or accuracy if you are ok with a greater error margin.
]]

Sensor.location = 'lightsensors'

function Sensor:setup(options)
	self.config.calibration=options.calibration or Sensor.calibration
	self.config.accuracy=options.accuracy or Sensor.accuracy
	self.config.maxRead=options.maxRead or Sensor.maxRead
	local pin = options.pin
	self.config.pin = pin
	self.gpio = RPIO(pin)
end

function Sensor:read()
	local lastread = self.config.lastRead
	local accuracy = self.adjAccuracy or self.config.accuracy
	function readL(pin)
		local reading = self.config.maxRead
		local time1 = socket:gettime()*1000
		self.gpio:set_direction('out')
		self.gpio:write(0)
		sleep(.1)
		self.gpio:set_direction('in')
		while self.gpio:read() == 0 do
			reading = reading - self.config.calibration
			if reading <= 0 then return math.round(socket:gettime()*1000 - time1,1),true end
		end
		return math.round(socket:gettime()*1000 - time1,1)
	end
	local reads = {}

	for _=1,accuracy do
		local reading,er = readL(self:getID())
		if not er then
			table.insert(reads,reading)
		end
	end
	if #reads > 1 then
		self.adjAccuracy = nil
		self:updateLastRead(table.median(reads))
		return self.config.lastRead,self:lightLevel(self.config.lastRead)
	else
		if not self.adjAccuracy then
			self.adjAccuracy = self.config.accuracy - 1
		elseif self.adjAccuracy > 2 then
			self.adjAccuracy = self.adjAccuracy - 1
		end
		--self:updateLastRead(self.config.lastRead)
		return nil,nil,'error'
	end
end

function Sensor:lightLevel(reading)
	if not reading then return nil end
	local level = 'dark'
	local levels = {{'bright',0},{'light',100},{'high light',200},{'mid light',300},{'low light',400},{'dark',500}}
	for i,v in ipairs(levels) do
		if reading >= v[2] then
			level = v[1]
		end
	end
	return level
end

function Sensor:getLastRead()
	return self.config.lastRead,self:lightLevel(self.config.lastRead)
end

--- Stringifier for Cloneables.
function Sensor:toString()
	local t1,t2 = self:getLastRead()
	return string.format("[LightSensor] %s %s %s %s",self:getID(),self:getName(),t1 or 'er',t2 or 'er')
end

return Sensor
