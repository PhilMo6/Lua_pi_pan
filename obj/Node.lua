local Cloneable						= require("obj.Cloneable")
local Node						= Cloneable.clone()
--[[
	Node client object.
	Applied by a master to a client object when a client ip address matches a configured node in the main config file.
]]

function Node:initialize(client)
	self.config = {}
print('NEW NODE')
	self.client = client
	local addr, port = client:getAddress()
	self.ip = addr
	self.port = port
	client.node = self
	local msg = 'Request objects'
	if nodeList[self.ip].objects then
		msg = msg .. " ("
		for i,v in ipairs(nodeList[self.ip].objects) do
			msg = msg .. " " .. v
		end
		msg = msg .. " )"
	end
	Scheduler:queue(Event:new(function()
		self:send(msg)
	end, 10, false))
	table.insert(nodes,self)
	nodes[addr] = self
	setNode(addr)
end



function Node:getHTMLcontrol()
	local ip,port = self:getAddress()
	return ([[%s %s]]):format(
	([[<button onclick="myFunction('Node %s stop')">Shutdown</button >]]):format(ip),
	([[<button onclick="myFunction('Node %s stop restart')">Restart</button >]]):format(ip)
	)
end



function Node:toString()
	if not self.client then
		return "Node@nil"
	end
	local addr, port = self.client:getAddress()
	return string.format("Node@%s", addr)
end

function Node:receive(pattern, prefix)
	return self.client:receive(pattern, prefix)
end

function Node:send(data, i, j)
	return self.client:send(data, i, j)
end

function Node:getAddress()
	return self.ip,self.port
end

function Node:getID()
	return nodeList[self.ip].id
end

function Node:addStepperMotors(motor)
	if self.stepperMotors == nil then
		self.stepperMotors = {}
		self:send('Request StepMs')
	end
	if self.stepperMotors[motor:getID()] == nil then
		self.stepperMotors[motor:getID()] = motor
		self.stepperMotors[motor:getName()] = motor
		table.insert(self.stepperMotors, motor)
		motor.node = self
	end
end

function Node:addButton(button)
	if self.buttons == nil then
		self.buttons = {}
	end
	if self.buttons[button:getID()] == nil then
		self.buttons[button:getID()] = button
		self.buttons[button:getName()] = button
		table.insert(self.buttons, button)
		button.node = self
	end
end

function Node:addDHT22(DHT22)
	if self.DHT22s == nil then
		self.DHT22s = {}
		self:send('Request SenDHT22')
	end
	if self.DHT22s[DHT22:getID()] == nil then
		self.DHT22s[DHT22:getID()] = DHT22
		self.DHT22s[DHT22:getName()] = DHT22
		table.insert(self.DHT22s, DHT22)
		DHT22.node = self
	end
end

function Node:addSensor(sensor)
	if self.sensors == nil then
		self.sensors = {}
		self:send('Request SenTemp')
	end
	if self.sensors[sensor:getID()] == nil then
		self.sensors[sensor:getID()] = sensor
		self.sensors[sensor:getName()] = sensor
		table.insert(self.sensors, sensor)
		sensor.node = self
	end
end

function Node:addLSensor(sensor)
	if self.lightsensors == nil then
		self.lightsensors = {}
		self:send('Request SenLight')
	end
	if self.lightsensors[sensor:getID()] == nil then
		self.lightsensors[sensor:getID()] = sensor
		self.lightsensors[sensor:getName()] = sensor
		table.insert(self.lightsensors, sensor)
		sensor.node = self
	end
end

function Node:addRelay(relay)
	if self.relays == nil then
		self.relays = {}
		self:send('Request RlUp')
	end
	if self.relays[relay:getID()] == nil then
		self.relays[relay:getID()] = relay
		self.relays[relay:getName()] = relay
		table.insert(self.relays, relay)
		relay.node = self
	end
end

function Node:addLED(LED)
	if self.LEDs == nil then
		self.LEDs = {}
		self:send('Request LEDUp')
	end
	if self.LEDs[LED:getID()] == nil then
		self.LEDs[LED:getID()] = LED
		self.LEDs[LED:getName()] = LED
		table.insert(self.LEDs, LED)
		LED.node = self
	end
end

function Node:addThermostat(thermostat)
	if self.thermostats == nil then
		self.thermostats = {}
		self:send('Request ThUp')
	end
	if self.thermostats[thermostat:getID()] == nil then
		self.thermostats[thermostat:getID()] = thermostat
		self.thermostats[thermostat:getName()] = thermostat
		table.insert(self.thermostats, thermostat)
		thermostat.node = self
	end
end

function Node:addMotionSensor(sensor)
	if self.motionSensors == nil then
		self.motionSensors = {}
		self:send('Request MosUp')
	end
	if self.motionSensors[sensor:getID()] == nil then
		self.motionSensors[sensor:getID()] = sensor
		self.motionSensors[sensor:getName()] = sensor
		table.insert(self.motionSensors, sensor)
		sensor.node = self
	end
end

function Node:addMacScanner(scanner)
	if self.macScanners == nil then
		self.macScanners = {}
	end
	if self.macScanners[scanner:getID()] == nil then
		self.macScanners[scanner:getID()] = scanner
		self.macScanners[scanner:getName()] = scanner
		table.insert(self.macScanners, scanner)
		scanner.node = self
	end
end

function Node:removeStepperMotors(motor)
	self.stepperMotors[motor:getID()] = nil
	self.stepperMotors[motor:getName()] = nil
	while table.removeValue(self.stepperMotors, motor) do end
	if motor.node then motor.node = nil motor:removeSelf() end
	if #self.stepperMotors == 0 then
		self.stepperMotors = nil
	end
end

function Node:removeButton(button)
	self.buttons[button:getID()] = nil
	self.buttons[button:getName()] = nil
	while table.removeValue(self.buttons, button) do end
	if button.node then button.node = nil button:removeButton() end
	if #self.buttons == 0 then
		self.buttons = nil
	end
end

function Node:removeDHT22(DHT22)
	self.DHT22s[DHT22:getID()] = nil
	self.DHT22s[DHT22:getName()] = nil
	while table.removeValue(self.DHT22s, DHT22) do end
	if DHT22.node then DHT22.node = nil DHT22:removeSensor() end
	if #self.DHT22s == 0 then
		self.DHT22s = nil
		if self.updateDHT22s then Scheduler:dequeue(self.updateDHT22s) self.updateDHT22s = nil end
	end
end

function Node:removeSensor(sensor)
	self.sensors[sensor:getID()] = nil
	self.sensors[sensor:getName()] = nil
	while table.removeValue(self.sensors, sensor) do end
	if sensor.node then sensor.node = nil sensor:removeSensor() end
	if #self.sensors == 0 then
		self.sensors = nil
	end
end

function Node:removeLSensor(sensor)
	self.lightsensors[sensor:getID()] = nil
	self.lightsensors[sensor:getName()] = nil
	while table.removeValue(self.lightsensors, sensor) do end
	if sensor.node then sensor.node = nil sensor:removeSensor() end
	if #self.lightsensors == 0 then
		self.lightsensors = nil
	end
end

function Node:removeRelay(relay)
	self.relays[relay:getID()] = nil
	self.relays[relay:getName()] = nil
	while table.removeValue(self.relays, relay) do end
	if relay.node then relay.node = nil relay:removeRelay() end
	if #self.relays == 0 then
		self.relays = nil
	end
end

function Node:removeLED(LED)
	self.LEDs[LED:getID()] = nil
	self.LEDs[LED:getName()] = nil
	while table.removeValue(self.LEDs, LED) do end
	if LED.node then LED.node = nil LED:removeLED() end
	if #self.LEDs == 0 then
		self.LEDs = nil
	end
end

function Node:removeThermostat(thermostat)
	self.thermostats[thermostat:getID()] = nil
	self.thermostats[thermostat:getName()] = nil
	while table.removeValue(self.thermostats, thermostat) do end
	if thermostat.node then thermostat.node = nil thermostat:removeThermostat() end
	if #self.thermostats == 0 then
		self.thermostats = nil
	end
end

function Node:removeMotionSensor(sensor)
	self.motionSensors[sensor:getID()] = nil
	self.motionSensors[sensor:getName()] = nil
	while table.removeValue(self.motionSensors, sensor) do end
	if sensor.node then sensor.node = nil sensor:removeSensor() end
	if #self.motionSensors == 0 then
		self.motionSensors = nil
	end
end

function Node:removeMacScanner(scanner)
	self.macScanners[scanner:getID()] = nil
	self.macScanners[scanner:getName()] = nil
	while table.removeValue(self.macScanners, scanner) do end
	if scanner.node then scanner.node = nil scanner:removeMacScanner() end
	if #self.macScanners == 0 then
		self.macScanners = nil
	end
end

function Node:destoy()
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

function Node:removeNode()
	if runningServer and self.client and self.client.socket then
		runningServer:disconnectClient(self.client)
	end
	self:destoy()
end

return Node
