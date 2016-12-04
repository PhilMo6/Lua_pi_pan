local Cloneable			= require("obj.Remote_Common")
local Sensor			= Cloneable:clone()
--[[
	Remote object for motion sensors attached to nodes.
	Node will update the remote sensors config as changes are detected.
	This also updates its current state and action.
]]

Sensor.location = 'motionSensors'

function Sensor:initialize(id,config,node)
	if not _G.motionSensors then _G.motionSensors = {name='motionSensors'} table.insert(objects,motionSensors) objects["motionSensors"] = motionSensors end
	if not motionSensors[id..'_'..node:getID()] then
		self.config = {}
		self.config.lightSensor 		= config and config.lightSensor or Sensor.config.lightSensor
		self.config.lightSensitivity	= config and config.lightSensitivity or Sensor.config.lightSensitivity
		self.config.button 				= config and config.button or Sensor.config.button
		self.config.relay  				= config and config.relay or Sensor.config.relay
		self.config.LED	   				= config and config.LED or Sensor.config.LED
		self.config.buzzer		 		= config and config.buzzer or Sensor.config.buzzer
		self.config.sensitivity 		= config and config.sensitivity or Sensor.config.sensitivity
		self.config.timeOut		 		= config and config.timeOut or Sensor.config.timeOut
		self.config.state 			= ""
		self.config.action 			= ""


		self:setID(id)
		self:setName(id..'_'..node:getID())
		table.insert(motionSensors,self)
		node:addMotionSensor(self)
	end
end

function Sensor:removeSensor()
	motionSensors[self:getName()] = nil
	motionSensors[self:getID()] = nil
	while table.removeValue(motionSensors, self) do end
	if self.node then local node=self.node self.node=nil node:removeMotionSensor(self) end
end

function Sensor:setState(state)
	if self.config.state and self.node and state ~= self.config.state then self.node:send(([[Mos %s setState %s]]):format(self:getID(),state)) end
end

function Sensor:setLightSensor(sensorID)
	if self.node then self.node:send(([[Mos %s setLightSensor %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setButton(buttonID)
	if self.node then self.node:send(([[Mos %s setButton %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setRelay(relayID)
	if self.node then self.node:send(([[Mos %s setRelay %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setLED(LEDID)
	if self.node then self.node:send(([[Mos %s setLED %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setBuzzer(buzzerID)
	if self.node then self.node:send(([[Mos %s setBuzzer %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setSensitivity(amt)
	if self.node then self.node:send(([[Mos %s setSensitivity %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setTimeOut(amt)
	if self.node then self.node:send(([[Mos %s setTimeOut %s]]):format(self:getID(),sensorID)) end
end

function Sensor:setID(id)
	if self.config.id then
		if self.node then
			self.node.motionSensors[self.config.id] = nil
			self.node.motionSensors[id] = self
		end
	end
	self.config.id = id
end

function Sensor:setName(name)
	if self.config.name then
		motionSensors[self.config.name] = nil
		if self.node then
			self.node:send(([[Mos %s rename %s]]):format(self:getID(),name))
			self.node.motionSensors[self.config.name] = nil
			self.node.motionSensors[name] = self
		end
	end
	self.config.name = name
	motionSensors[self.config.name] = self
end

--- Stringifier for Cloneables.
function Sensor:toString()
	return string.format("[Remote_MotionSensor] %s %s %s %s",self:getID(),self:getName(),self:getState(),self:getAction())
end

--remote so these functions run on the node and on this object must do nil
function Sensor:runLogic()
end
function Sensor:checkLight()
end
function Sensor:checkMotion()
end
function Sensor:setAction()
end

return Sensor
