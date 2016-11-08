local Cloneable			= require("obj.Sensor")
local DHT22			= Cloneable:clone()

--[[
	DHT22 tempature and humidity sensor. connect as in the following
	https://learn.adafruit.com/dht-humidity-sensing-on-raspberry-pi-with-gdocs-logging/wiring
	NOT APPLICABLE TO DHT11. will work on that in the future.
	!This is a high processer use object so use with care!
]]

DHT22.updateCmd = "Request SenDHT22"

function DHT22:initialize(pin)
	if not _G.DHT22s then _G.DHT22s = {name='DHT22s'} table.insert(objects,DHT22s) objects["DHT22s"] = DHT22s startPollSensorEvent() end
	if not DHT22s['DHT22_' ..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('DHT22_' ..pin)
		self.lastTRead = 0
		self.lastHRead = 0
		table.insert(DHT22s,self)
		self.gpio = RPIO(pin)
		self:read()
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
	local h,t
	for i=1,6 do
		h,t = self:pollSensor()
		if h then break end
		sleep(1)
	end
	if h then
		local up = (self.lastHRead ~= h and true or self.lastTRead ~= t and true or nil)
		self.lastHRead = h
		self.lastTRead = t
		if self.masters and up then
			self:updateMasters()
		end
	end
	return h,t
end

--this is based off of work found here https://github.com/javieryanez/nodemcu-modules/tree/master/dht22
function DHT22:pollSensor()
	collectgarbage()
	sleep(1)
	local pin = self:getID()
	local checksum
	local checksumTest
	local hRead = 0
	local tRead = 0

	checksum = 0
	local bitStream = {}
	for j = 1, 40, 1 do
		bitStream[j] = 0
	end
	local bitlength = 0
	local c1=0
	local c2=0

	-- Step 1:  send out start signal to DHT22
	self.gpio:set_direction('out')
	self.gpio:write(1)
	sleep(0.0015)
	self.gpio:write(0)
	sleep(0.004)
	self.gpio:set_direction('in')

	-- Step 2:  DHT22 send response signal
	-- bus will always let up eventually, don't bother with timeout
	while (self.gpio:read() == 0 ) do end
	while (self.gpio:read() == 1 and c1 < 100) do c1 = c1 + 1 end
	-- bus will always let up eventually, don't bother with timeout
	while (self.gpio:read() == 0 ) do end
	while (self.gpio:read() == 1 and c2 < 100) do c2 = c2 + 1 end
	while (self.gpio:read() == 0) do end

	-- Step 3: DHT22 send data
	for j = 1, 40, 1 do
		while (self.gpio:read() == 1 and bitlength < 60) do
			bitlength = bitlength + 1
		end
		bitStream[j] = bitlength
		bitlength = 0
		while (self.gpio:read() == 0) do end
	end

	local biterr = 25
	--DHT data acquired, process.
	for i = 1, 16, 1 do
		if bitStream[i] > biterr then
			hRead = hRead + 2 ^ (16 - i)
		end
	end
	for i = 1, 16, 1 do
		if bitStream[i + 16] > biterr then
			tRead = tRead + 2 ^ (16 - i)
		end
	end
	for i = 1, 8, 1 do
		if bitStream[i + 32] > biterr then
			checksum = checksum + 2 ^ (8 - i)
		end
	end

	checksumTest = (bit32.band(hRead, 0xFF) + bit32.rshift(hRead, 8) + bit32.band(tRead, 0xFF) + bit32.rshift(tRead, 8))
	checksumTest = bit32.band(checksumTest, 0xFF)
	if tRead > 0x8000 then
		-- convert to negative format
		tRead = -(tRead - 0x8000)
	end

	-- conditions compatible con float point and integer
	if (checksumTest - checksum >= 1) or (checksum - checksumTest >= 1) then
		hRead = nil
	end

	self.gpio:set_direction('out')
	self.gpio:write(1)
	return (hRead and ((hRead - (hRead % 10)) / 10).."."..(hRead % 10) or nil),(tRead and ((tRead-(tRead % 10)) / 10).."."..(tRead % 10) or nil)

end

function DHT22:getLastRead()
	return self.lastTRead,self.lastHRead
end

--- Stringifier for Cloneables.
function DHT22:toString()
	local t,h = self:getLastRead()
	return string.format("[DHT22] %s %s %sC %s%%",self:getID(),self:getName(),t or 'nil',h or 'nil')
end

return DHT22
