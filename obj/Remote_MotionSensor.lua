local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.MotionSensor")
local Sensor			= Cloneable:clone()
--[[
	Remote object for motion sensors attached to nodes.
	Node will update the remote sensors config as changes are detected.
	This also updates its current state and action.
]]


Sensor.location = origin.location
Sensor.config = origin.config
Sensor.getState = origin.getState
Sensor.getAction = origin.getAction
Sensor.getLightSensor = origin.getLightSensor
Sensor.getLightSensitivity = origin.getLightSensitivity
Sensor.getRelay = origin.getRelay
Sensor.getLED = origin.getLED
Sensor.getBuzzer = origin.getBuzzer
Sensor.getSensitivity = origin.getSensitivity
Sensor.getTimeOut = origin.getTimeOut
Sensor.toggle = origin.toggle
Sensor.getHTMLcontrol = origin.getHTMLcontrol

function Sensor:setup(options)
	self.config.lightSensor 		= options.lightSensor or Sensor.config.lightSensor
	self.config.lightSensitivity	= options.lightSensitivity or Sensor.config.lightSensitivity
	self.config.button 				= options.button or Sensor.config.button
	self.config.relay  				= options.relay or Sensor.config.relay
	self.config.LED	   				= options.LED or Sensor.config.LED
	self.config.buzzer		 		= options.buzzer or Sensor.config.buzzer
	self.config.sensitivity 		= options.sensitivity or Sensor.config.sensitivity
	self.config.timeOut		 		= options.timeOut or Sensor.config.timeOut
	self.config.state 				= options.state
	self.config.action 				= options.action
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
