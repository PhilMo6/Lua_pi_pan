local Cloneable						= require("obj.Cloneable")
local Master						= Cloneable.clone()
--[[
	Master client object.
	Applied by a node to a client object when a clients ip address matches a configured master in the main config file.
]]

function Master:initialize(client)
	self.config = {}
print('NEW MASTER')
	self.client = client
	local addr, port = client:getAddress()
	self.ip = addr
	self.port = port
	client.master = self
	table.insert(masters,self)
	masters[addr] = self
	runningServer:ping(self)
end

function Master:addButton(button)
	if self.buttons == nil then
		self.buttons = {}
	end
	if not self.buttons[button] then
		self.buttons[button] = button
		self.buttons[button:getName()] = button
		table.insert(self.buttons, button)
		button:addMaster(self)
	end
end

function Master:addDHT22(DHT22)
	if self.DHT22s == nil then
		self.DHT22s = {}
	end
	if not self.DHT22s[DHT22] then
		self.DHT22s[DHT22] = DHT22
		self.DHT22s[DHT22:getName()] = DHT22
		table.insert(self.DHT22s, DHT22)
		DHT22:addMaster(self)
	end
end

function Master:addSensor(sensor)
	if self.sensors == nil then
		self.sensors = {}
	end
	if not self.sensors[sensor] then
		self.sensors[sensor] = sensor
		self.sensors[sensor:getName()] = sensor
		table.insert(self.sensors, sensor)
		sensor:addMaster(self)
	end
end

function Master:addLSensor(sensor)
	if self.lightsensors == nil then
		self.lightsensors = {}
	end
	if not self.lightsensors[sensor] then
		self.lightsensors[sensor] = sensor
		self.lightsensors[sensor:getName()] = sensor
		table.insert(self.lightsensors, sensor)
		sensor:addMaster(self)
	end
end

function Master:addRelay(relay)
	if self.relays == nil then
		self.relays = {}
	end
	if not self.relays[relay] then
		self.relays[relay] = relay
		self.relays[relay:getName()] = relay
		table.insert(self.relays, relay)
		relay:addMaster(self)
	end
end

function Master:addLED(LED)
	if self.LEDs == nil then
		self.LEDs = {}
	end
	if not self.LEDs[LED] then
		self.LEDs[LED] = LED
		self.LEDs[LED:getName()] = LED
		table.insert(self.LEDs, LED)
		LED:addMaster(self)
	end
end

function Master:addThermostat(thermostat)
	if self.thermostats == nil then
		self.thermostats = {}
	end
	if not self.thermostats[thermostat] then
		self.thermostats[thermostat] = thermostat
		self.thermostats[thermostat:getName()] = thermostat
		table.insert(self.thermostats, thermostat)
		thermostat:addMaster(self)
	end
end

function Master:addMotionSensor(sensor)
	if self.motionSensors == nil then
		self.motionSensors = {}
	end
	if self.motionSensors[sensor] == nil then
		self.motionSensors[sensor] = sensor
		self.motionSensors[sensor:getName()] = sensor
		table.insert(self.motionSensors, sensor)
		sensor:addMaster(self)
	end
end

function Master:addMacScanner(scanner)
	if self.macScanners == nil then
		self.macScanners = {}
	end
	if self.macScanners[scanner] == nil then
		self.macScanners[scanner] = scanner
		self.macScanners[scanner:getName()] = scanner
		table.insert(self.macScanners, scanner)
		scanner:addMaster(self)
	end
end

function Master:removeButton(button)
	self.buttons[button] = nil
	self.buttons[button:getName()] = nil
	while table.removeValue(self.buttons, button) do end
	button:removeMaster(self)
	if #self.buttons == 0 then
		self.buttons = nil
	end
end

function Master:removeDHT22(DHT22)
	self.DHT22s[DHT22] = nil
	self.DHT22s[DHT22:getName()] = nil
	while table.removeValue(self.DHT22s, DHT22) do end
	DHT22:removeMaster(self)
	if #self.DHT22s == 0 then
		self.DHT22s = nil
	end
end

function Master:removeSensor(sensor)
	self.sensors[sensor] = nil
	self.sensors[sensor:getName()] = nil
	while table.removeValue(self.sensors, sensor) do end
	sensor:removeMaster(self)
	if #self.sensors == 0 then
		self.sensors = nil
	end
end

function Master:removeLSensor(sensor)
	self.lightsensors[sensor] = nil
	self.lightsensors[sensor:getName()] = nil
	while table.removeValue(self.lightsensors, sensor) do end
	sensor:removeMaster(self)
	if #self.lightsensors == 0 then
		self.lightsensors = nil
	end
end

function Master:removeRelay(relay)
	self.relays[relay] = nil
	self.relays[relay:getName()] = nil
	while table.removeValue(self.relays, relay) do end
	relay:removeMaster(self)
	if #self.relays == 0 then
		self.relays = nil
	end
end

function Master:removeLED(LED)
	self.LEDs[LED] = nil
	self.LEDs[LED:getName()] = nil
	while table.removeValue(self.LEDs, LED) do end
	LED:removeMaster(self)
	if #self.LEDs == 0 then
		self.LEDs = nil
	end
end

function Master:removeThermostat(thermostat)
	self.thermostats[thermostat] = nil
	self.thermostats[thermostat:getName()] = nil
	while table.removeValue(self.thermostats, thermostat) do end
	thermostat:removeMaster(self)
	if #self.thermostats == 0 then
		self.thermostats = nil
	end
end

function Master:removeMotionSensor(sensor)
	self.motionSensors[sensor] = nil
	self.motionSensors[sensor:getName()] = nil
	while table.removeValue(self.motionSensors, sensor) do end
	sensor:removeMaster(self)
	if #self.motionSensors == 0 then
		self.motionSensors = nil
	end
end

function Master:removeMacScanner(scanner)
	self.macScanners[scanner] = nil
	self.macScanners[scanner:getName()] = nil
	while table.removeValue(self.macScanners, scanner) do end
	scanner:removeMaster(self)
	if #self.macScanners == 0 then
		self.macScanners = nil
	end
end

function Master:toString()
	if not self.client then
		return "Master@nil"
	end
	local addr, port = self.client:getAddress()
	return string.format("Master@%s", addr)
end

function Master:receive(pattern, prefix)
	return self.client:receive(pattern, prefix)
end

function Master:send(data, i, j)
	return self.client:send(data, i, j)
end

function Master:getAddress()
	return self.ip,self.port
end

function Master:getID()
	return masterList[self.ip].id
end

function Master:removeMaster()
	if runningServer and self.client and self.client.socket then
		runningServer:disconnectClient(self.client)
	end
	self:destoy()
end

function Master:destoy()
	if self.buttons then
		for i,v in pairs(self.buttons) do
			self:removeButton(v)
		end
	end
	if self.DHT22s then
		for i,v in pairs(self.DHT22s) do
			self:removeDHT22(v)
		end
	end
	if self.sensors then
		for i,v in pairs(self.sensors) do
			self:removeSensor(v)
		end
	end
	if self.lightsensors then
		for i,v in pairs(self.lightsensors) do
			self:removeLSensor(v)
		end
	end
	if self.relays then
		for i,v in pairs(self.relays) do
			self:removeRelay(v)
		end
	end
	if self.LEDs then
		for i,v in pairs(self.LEDs) do
			self:removeLED(v)
		end
	end
	if self.thermostats then
		for i,v in pairs(self.thermostats) do
			self:removeThermostat(v)
		end
	end
	if self.motionSensors then
		for i,v in pairs(self.motionSensors) do
			self:removeMotionSensor(v)
		end
	end
	if self.macScanners then
		for i,v in pairs(self.macScanners) do
			self:removeMacScanner(v)
		end
	end
	self = nil
end

return Master
