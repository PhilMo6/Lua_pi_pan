local Cloneable			= require("obj.Remote_Common")
local origin 			= require("obj.Thermostat")
local Thermostat			= Cloneable:clone()
--[[
	Remote object for thermostats attached to nodes.
	Node will update the thermostats config as changes are detected.
	This also updates its current state and action.
]]


Thermostat.location = origin.location
Thermostat.getHTMLcontrol = origin.getHTMLcontrol

Thermostat.getUpTime = origin.getUpTime
Thermostat.getTempSensor = origin.getTempSensor
Thermostat.getHeatRelay = origin.getHeatRelay
Thermostat.getCoolRelay = origin.getCoolRelay
Thermostat.getCoolTh = origin.getCoolTh
Thermostat.getHeatTh = origin.getHeatTh
Thermostat.getTempTh = origin.getTempTh
Thermostat.getTemp = origin.getTemp
Thermostat.read = origin.read
Thermostat.getStatus = origin.getStatus
Thermostat.getState = origin.getState
Thermostat.getAction = origin.getAction
Thermostat.toggle = origin.toggle

function Thermostat:setup(options)

end

--remote so these functions run on the node and on this object must do nil

function Thermostat:setUpTime(ut)
	if self.node then self.node:send(([[Therm %s uptime %s]]):format(self:getID(),ut)) end
end

function Thermostat:setTempSensor(sensorID)
	if self.node then self.node:send(([[Therm %s sensor %s]]):format(self:getID(),sensorID)) end
end

function Thermostat:setHeatRelay(relayID)
	if self.node then self.node:send(([[Therm %s heatRelay %s]]):format(self:getID(),relayID)) end
end

function Thermostat:setCoolRelay(relayID)
	if self.node then self.node:send(([[Therm %s coldRelay %s]]):format(self:getID(),relayID)) end
end

function Thermostat:setCoolTh(th,user)
	if self.node then self.node:send(([[Therm %s cts %s]]):format(self:getID(),th)) end
end

function Thermostat:setHeatTh(th)
	if self.node then self.node:send(([[Therm %s hts %s]]):format(self:getID(),th)) end
end

function Thermostat:setTempTh(th)
	if self.node then self.node:send(([[Therm %s ths %s]]):format(self:getID(),th)) end
end

function Thermostat:setTemp(temp)
	if self.node then self.node:send(([[Therm %s tps %s]]):format(self:getID(),temp)) end
end

function Thermostat:setState(state)
	if self.config.state and self.node and state ~= self.config.state then self.node:send(([[Therm %s setState %s]]):format(self:getID(),state)) end
end

--- Stringifier for Cloneables.
function Thermostat:toString()
	local t1,t2 = 0,0
	if self.config.tempSensorID and objectIDs[self.config.tempSensorID] then t1,t2 = objectIDs[self.config.tempSensorID]:getLastRead() end
	return string.format("[Remote_Thermostat] %s current temp:%s state:%s action:%s",self:getName(),t2,self:getState(),self:getAction())
end

return Thermostat
