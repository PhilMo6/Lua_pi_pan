local Command	= require("obj.Command")

--- Thermostat command
local Thermostat		= Command:clone()
Thermostat.name = "Thermostat"
Thermostat.keywords	= {"thermostat","Therm","therm"}

--- Execute the command
function Thermostat:execute(input,user)
	if not thermostats then return "No thermostats!" end
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]
	if input2 then--input2 should be the id(pin) or index of a Thermostat
		local thermostat = thermostats[input2] or thermostats[tonumber(input2)]
		if thermostat then --That is a vaild Thermostat
			if input3 then--input3 should be the order to execute
				if Thermostat.orders[input3] then--This is a valid order
					return Thermostat.orders[input3](thermostat,input4)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Thermostat."
		end
	else
		return "Please select a Thermostat when issuing a Thermostat command"
	end
end

Thermostat.orders={}

Thermostat.orders["toggle"] = function(thermostat)
	thermostat:toggle()
	updateThermostatInfo()
	return thermostat:toString()
end

Thermostat.orders["heatRelay"] = function(thermostat,relayID)
	if relayID then
		thermostat:setHeatRelay(relayID)
		updateThermostatInfo()
		return ("Thermostat heating relay now set to %s."):format(thermostat:getTempSensor())
	else
		return "Must supply a relay ID."
	end
end

Thermostat.orders["coldRelay"] = function(thermostat,relayID)
	if relayID then
		thermostat:setCoolRelay(relayID)
		updateThermostatInfo()
		return ("Thermostat cooling relay now set to %s."):format(thermostat:getCoolRelay())
	else
		return "Must supply a relay ID."
	end
end

Thermostat.orders["sensor"] = function(thermostat,sensorID)
	if sensorID then
		thermostat:setTempSensor(sensorID)
		updateThermostatInfo()
		return ("Thermostat temp sensor now set to %s."):format(thermostat:getTempSensor())
	else
		return "Must supply a sensorID."
	end
end

Thermostat.orders["uptime"] = function(thermostat,uptime)
	if uptime then
		thermostat:setUpTime(tonumber(uptime))
		updateThermostatInfo()
		return ("Thermostat now set to %s F."):format(thermostat:getTemp())
	else
		return "Must supply an uptime."
	end
end


Thermostat.orders["setState"] = function(thermostat,state)
	if state then
		thermostat:setState(state)
		return thermostat:toString()
	else
		return "Must supply a state."
	end
end

Thermostat.orders["rename"] = function(thermostat,name)
	if name then
		thermostat:setName(name)
		updateThermostatInfo()
		return string.format("Thermostat %s has been renamed %s.",relay:getID(),relay:getName())
	else
		return "Must supply a name to rename a Relay."
	end
end

Thermostat.orders["setID"] = function(thermostat,id)
	if id then
		thermostat:setID(id)
		return string.format("Thermostat %s has had its id set to %s.",relay:getName(),relay:getID())
	else
		return "Must supply an ID..."
	end
end

Thermostat.orders['stat'] = function(thermostat)
	return thermostat:getStatus()
end
Thermostat.orders['s'] = Thermostat.orders['stat']

Thermostat.orders['up'] = function(thermostat,amt)
	thermostat:setTemp(thermostat:getTemp() + (amt or  1))
	updateThermostatInfo()
	return ("Thermostat now set to %s F."):format(thermostat:getTemp())
end
Thermostat.orders['u'] = Thermostat.orders['up']

Thermostat.orders['down'] = function(thermostat,amt)
	thermostat:setTemp(thermostat:getTemp() - (amt or 1))
	updateThermostatInfo()
	return ("Thermostat now set to %s F."):format(thermostat:getTemp())
end
Thermostat.orders['d'] = Thermostat.orders['down']

Thermostat.orders['tempset'] = function(thermostat,amt)
	if amt then thermostat:setTemp(amt) else return "Please enter ammount with command..." end
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getTemp())
end
Thermostat.orders['tps'] = Thermostat.orders['tempset']


Thermostat.orders['thresholdup'] = function(thermostat,amt)
	thermostat:setTempTh(thermostat:getTempTh() + (amt or 1))
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getTempTh())
end
Thermostat.orders['thu'] = Thermostat.orders['thresholdup']

Thermostat.orders['thresholddown'] = function(thermostat,amt)
	thermostat:setTempTh(thermostat:getTempTh() - (amt or 1))
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getTempTh())
end
Thermostat.orders['thd'] = Thermostat.orders['thresholddown']

Thermostat.orders['thresholdset'] = function(thermostat,amt)
	if amt then thermostat:setTempTh(amt) else return "Please enter ammount with command..." end
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getTempTh())
end
Thermostat.orders['ths'] = Thermostat.orders['thresholdset']


Thermostat.orders['coolthresholdup'] = function(thermostat,amt)
	thermostat:setCoolTh(thermostat:getCoolTh() + (amt or 1))
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getCoolTh())
end
Thermostat.orders['ctu'] = Thermostat.orders['coolthresholdup']

Thermostat.orders['coolthresholddown'] = function(thermostat,amt)
	thermostat:setCoolTh(thermostat:getCoolTh() - (amt or 1))
	updateThermostatInfo()
	return ("Thermostat cooling threshold now set to %s"):format(thermostat:getCoolTh())
end
Thermostat.orders['ctd'] = Thermostat.orders['coolthresholddown']

Thermostat.orders['coolthresholdset'] = function(thermostat,amt)
	if amt then thermostat:setCoolTh(amt) else return "Please enter ammount with command..." end
	updateThermostatInfo()
	return ("Thermostat cooling threshold now set to %s"):format(thermostat:getCoolTh())
end
Thermostat.orders['cts'] = Thermostat.orders['coolthresholdset']


Thermostat.orders['heatthresholdup'] = function(thermostat,amt)
	thermostat:setHeatTh(thermostat:getHeatTh() + (amt or 1))
	updateThermostatInfo()
	return ("Thermostat threshold now set to %s"):format(thermostat:getHeatTh())
end
Thermostat.orders['htu'] = Thermostat.orders['heatthresholdup']

Thermostat.orders['heatthresholddown'] = function(thermostat,amt)
	thermostat:setHeatTh(thermostat:getHeatTh() - (amt or 1))
	updateThermostatInfo()
	return ("Thermostat heating threshold now set to %s"):format(thermostat:getHeatTh())
end
Thermostat.orders['htd'] = Thermostat.orders['heatthresholddown']

Thermostat.orders['heatthresholdset'] = function(thermostat,amt)
	if amt then thermostat:setHeatTh(amt) else return "Please enter ammount with command..." end
	updateThermostatInfo()
	return ("Thermostat heating threshold now set to %s"):format(thermostat:getHeatTh())
end
Thermostat.orders['hts'] = Thermostat.orders['heatthresholdset']



return Thermostat
