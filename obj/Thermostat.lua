local Cloneable			= require("obj.Cloneable")
local Thermostat			= Cloneable:clone()
--[[
	Object module for thermostats
	This is a 2nd level object and is dependent on other objects to be in place.
	You must set a temperature sensor.
	Optionaly you can set a cooling relay or a heating relay.
	These will be turned on based on the temperature threshold set.
	The cooling and heating thresholds change what temperature the corresponding relays will turn off.
	The thermostat state can be set to active(default), heating, cooling, or off
]]

Thermostat.updateCmd = "Request ThUp"
Thermostat.config = {}
Thermostat.config.temperature 					=  70
Thermostat.config.temperatureThreshold			= 1
Thermostat.config.heatThreshold					= 0
Thermostat.config.coolThreshold					= 0
Thermostat.config.updateTime					= 45
Thermostat.config.tempSensor					= 'inside'
Thermostat.config.heatingRelay					= 'heater'
Thermostat.config.coolingRelay					= 'fan'

--- Constructor for instance-style clones.
function Thermostat:initialize(id,config)
	if not _G.thermostats then _G.thermostats = {name="thermostats"} table.insert(objects,thermostats) objects["thermostats"] = thermostats end
	if not thermostats[id] then
		self.config = {}
		table.insert(thermostats,self)

		self:setID(id)
		self:setName('thermostat_'..id)

		self.config.temperature 					= (config and config.temperature or Thermostat.config.temperature)
		self.config.temperatureThreshold			= (config and config.temperatureThreshold or Thermostat.config.temperatureThreshold)
		self.config.heatThreshold					= (config and config.heatThreshold or Thermostat.config.heatThreshold)
		self.config.coolThreshold					= (config and config.coolThreshold or Thermostat.config.coolThreshold)
		self.config.updateTime						= (config and config.updateTime or Thermostat.config.updateTime)
		self.config.tempSensor						= (config and config.tempSensor or Thermostat.config.tempSensor)
		self.config.heatingRelay					= (config and config.heatingRelay or Thermostat.config.heatingRelay)
		self.config.coolingRelay					= (config and config.coolingRelay or Thermostat.config.coolingRelay)

		self:setState(config and config.state or 'active')
		self:setAction()
		local therm = self
		Scheduler:queue(Event:new(function()
			therm.updateLogic = Event:new(function()--trigger event that runs the thermostats logic
				therm:runLogic()
			end, therm:getUpTime(), true, 0)
			Scheduler:queue(therm.updateLogic)
			therm:runLogic()
		end, 15, false))
	end
end

function Thermostat:runLogic()
	if self:getState() == 'active' then
		self:runCoolLogic()
		self:runHeatLogic()
	elseif self:getState() == 'cooling' then
		self:runCoolLogic()
	elseif self:getState() == 'heating' then
		self:runHeatLogic()
	end
end

function Thermostat:runCoolLogic()
	if sensors[self:getTempSensor()] then
		if relays[self:getCoolRelay()] then
			local t1,t2 = sensors[self:getTempSensor()]:getLastRead()
			if t2 > (self:getTemp() + self:getTempTh()) and relays[self:getCoolRelay()]:readO() == true then
				if relays[self:getCoolRelay()]:on() then self:setAction('cooling') end
			elseif t2 <= (self:getTemp() - self:getCoolTh()) and relays[self:getCoolRelay()]:readO() == false then
				if relays[self:getCoolRelay()]:off() then self:setAction() end
			end
		end
	end
end

function Thermostat:runHeatLogic()
	if sensors[self:getTempSensor()] then
		if relays[self:getHeatRelay()] then
			local t1,t2 = sensors[self:getTempSensor()]:getLastRead()
			if t2 < (self:getTemp() - self:getTempTh()) and relays[self:getHeatRelay()]:readO() == true then
				if relays[self:getHeatRelay()]:on() then self:setAction('heating') end
			elseif t2 >= (self:getTemp() + self:getHeatTh()) and relays[self:getHeatRelay()]:readO() == false then
				if relays[self:getHeatRelay()]:off() then self:setAction() end
			end
		end
	end
end

function Thermostat:setConfig(config)
	if not config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'name' then
				self:setName(config[i])
			elseif i == 'id' then
				self:setID(config[i])
			else
				self.config[i] = config[i]
			end
			up = true
		end
	end
	if up then	self:updateMasters() end
end

function Thermostat:setUpTime(ut)
	self.config.updateTime = ut
	logEvent(self:getName(),self:getName() .. ' setUpTime:'..ut)
	self:updateMasters()
end

function Thermostat:getUpTime()
	return self.config.updateTime
end

function Thermostat:setTempSensor(sensorID)
	self.config.tempSensor = sensorID
	logEvent(self:getName(),self:getName() .. ' setTempSensor:'..sensorID)
	self:updateMasters()
end

function Thermostat:getTempSensor()
	return self.config.tempSensor
end

function Thermostat:getTempSensorID()
	local id = "!"
	if self:getTempSensor() and sensors[self:getTempSensor()] then id = sensors[self:getTempSensor()]:getID() end
	return id
end

function Thermostat:setHeatRelay(relayID)
	self.config.heatingRelay = relayID
	logEvent(self:getName(),self:getName() .. ' setHeatRelay:'..relayID)
	self:updateMasters()
end

function Thermostat:getHeatRelay()
	return self.config.heatingRelay
end

function Thermostat:setCoolRelay(relayID)
	self.config.coolingRelay = relayID
	logEvent(self:getName(),self:getName() .. ' setCoolRelay:'..relayID)
	self:updateMasters()
end

function Thermostat:getCoolRelay()
	return self.config.coolingRelay
end

function Thermostat:setCoolTh(th)
	self.config.coolThreshold = th
	logEvent(self:getName(),self:getName() .. ' setCoolTh:'..th)
	self:updateMasters()
end

function Thermostat:getCoolTh()
	return self.config.coolThreshold
end

function Thermostat:setHeatTh(th)
	self.config.heatThreshold = th
	logEvent(self:getName(),self:getName() .. ' setHeatTh:'..th)
	self:updateMasters()
end

function Thermostat:getHeatTh()
	return self.config.heatThreshold
end

function Thermostat:setTempTh(th)
	self.config.temperatureThreshold = th
	logEvent(self:getName(),self:getName() .. ' setTempTh:'..th)
	self:updateMasters()
end

function Thermostat:getTempTh()
	return self.config.temperatureThreshold
end

function Thermostat:setTemp(temp)
	self.config.temperature = temp
	logEvent(self:getName(),self:getName() .. ' setTemp:'..temp)
	self:updateMasters()
end

function Thermostat:getTemp()
	return self.config.temperature
end

function Thermostat:setID(id)
	if self.config.id then thermostats[self.config.id] = nil self:updateMasters() logEvent(self:getName(),self:getName() .. ' setID:' .. id) end
	self.config.id = id
	thermostats[self.config.id] = self
end

function Thermostat:setName(name)
	if self.config.name then thermostats[self.config.name] = nil self:updateMasters() logEvent(self:getName(),self:getName() .. ' setName:' .. name) end
	self.config.name = name
	thermostats[self.config.name] = self
end

function Thermostat:setState(state)
	local states = {
	['active']=function() self:setAction() if relays and relays[self:getCoolRelay()] then relays[self:getCoolRelay()]:off() end if relays[self:getHeatRelay()] then relays[self:getHeatRelay()]:off() end end,
	['heating']=function() self:setAction() if relays and relays[self:getCoolRelay()] then relays[self:getCoolRelay()]:off() end end,
	['off']=function() self:setAction() if relays and relays[self:getCoolRelay()] then relays[self:getCoolRelay()]:off() end if relays[self:getHeatRelay()] then relays[self:getHeatRelay()]:off() end end,
	['cooling']=function() self:setAction() if relays and relays[self:getHeatRelay()] then relays[self:getHeatRelay()]:off() end end
	}
	if not state then state = 'active' end
	if self.config.state ~= state and states[state] then
		self.config.state = state
		if type(states[state]) == "function" then
			states[state]()
		end
		logEvent(self:getName(),self:getName() .. ' state:' .. state)
		self:runLogic()
		self:updateMasters()
	end
end

function Thermostat:setAction(action)
	local states = {['heating']='heating',['standby']='standby',['cooling']='cooling'}
	if not action then action = 'standby' end
	if states[action] and self.config.action ~= action then
		self.config.action = action
		logEvent(self:getName(),self:getName() .. ' action:' .. action)
		self:updateMasters()
	end
end

function Thermostat:getHTMLcontrol()
	local name = self:getName()
	return ('<div style="font-size:15px">%s %s <br>Temp %s %s <br> Temp Threshold %s %s <br> Cooling Threshold  %s %s <br> Heating Threshold %s %s <br>%s</div>'):format(
	([[<button style="font-size:15px" onclick="myFunction('Therm %s stat')">Status</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s toggle')">Toggle</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s up','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s down','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s thu','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s thd','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s ctu','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s ctd','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s htu','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Therm %s htd','%s')">-</button >]]):format(name,name),
	([[<form id="%s"> Adust by:<input type="text" name='com'></form>]]):format(name)
	)
end


function Thermostat:getID()
	return self.config.id
end

function Thermostat:getName()
	return self.config.name
end

function Thermostat:getState()
	return self.config.state or 'off'
end

function Thermostat:getAction()
	return self.config.action or 'standby'
end

function Thermostat:readO()
	return self:getState()
end

function Thermostat:toggle()
	logEvent(self:getName(),self:getName() .. ' toggle')
	if self:getState() == 'heating' then
		self:setState('cooling')
		return 'cooling'
	elseif self:getState() == 'cooling' then
		self:setState('off')
		return 'off'
	elseif self:getState() == 'off' then
		self:setState('active')
		return 'active'
	elseif self:getState() == 'active' then
		self:setState('heating')
		return 'heating'
	else
		self:setState('off')
		return 'off'
	end
end

function Thermostat:getStatus()
	local status = ""
	for i,v in pairs(self.config) do
		status = string.format([[%s
%s:%s]],status,i,v)
	end
	return string.format("%s%s",self:toString(),status)
end


--- Stringifier for Cloneables.
function Thermostat:toString()
	local t1,t2 = 0,0
	if sensors and sensors[self:getTempSensor()] then t1,t2 = sensors[self:getTempSensor()]:getLastRead() end
	return string.format("[Thermostat] %s current temp:%s state:%s action:%s",self:getName(),t2,self:getState(),self:getAction())
end

return Thermostat
