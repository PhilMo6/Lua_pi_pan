local Command	= require("obj.Command")

--- test command
local Sensor	= Command:clone()
Sensor.name = "MotionSensor"
Sensor.keywords	= {"Mosen","mosen","mos","Mos"}

--- Execute the command
function Sensor:execute(input,user)
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]

	if input2 then--input2 should be the id or index of a sensor
		local sensor = motionSensors[input2] or motionSensors[tonumber(input2)]
		if sensor then --That is a vaild sensor
			if input3 then--input3 should be the order to execute
				if Sensor.orders[input3] then--This is a valid order
					return Sensor.orders[input3](sensor,input4)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild sensor."
		end
	else
		return "Please select a sensor when issuing a sensor command"
	end
end

Sensor.orders = {}
Sensor.orders["rename"] = function(sensor,name)
	if name then
		sensor:setName(name)
		saveObjectsInfo()
		return string.format("Sensor %s has been renamed %s.",sensor:getID(),sensor:getName())
	else
		return "Must supply a name to rename a sensor."
	end
end
Sensor.orders["re"] = Sensor.orders["rename"]

Sensor.orders["setState"] = function(sensor,state)
	if state then
		sensor:setState(state)
		saveObjectsInfo()
		return string.format("Sensors state has been set to %s.",sensor:getID(),sensor:getState())
	else
		return "Must supply a state to set."
	end
end

Sensor.orders["stat"] = function(sensor)
	return sensor:getStatus()
end

Sensor.orders["toggle"] = function(sensor)
	sensor:toggle()
	saveObjectsInfo()
	return sensor:toString()
end

Sensor.orders["setLightSensor"] = function(sensor,id)
	if id then
		sensor:setLightSensor(id)
		saveObjectsInfo()
		return string.format("Sensors lightsensor has been set to %s.",sensor:getID(),sensor:getLightSensor())
	else
		return "Must supply an ID to set."
	end
end
Sensor.orders["sLS"]  = Sensor.orders["setLightSensor"]


Sensor.orders["setButton"] = function(sensor,id)
	if id then
		sensor:setButton(id)
		saveObjectsInfo()
		return string.format("Sensors button has been set to %s.",sensor:getID(),sensor:getButton())
	else
		return "Must supply an ID to set."
	end
end
Sensor.orders["sB"] = Sensor.orders["setButton"]

Sensor.orders["setRelay"] = function(sensor,id)
	if id then
		sensor:setRelay(id)
		saveObjectsInfo()
		return string.format("Sensors relay has been set to %s.",sensor:getID(),sensor:getRelay())
	else
		return "Must supply an ID to set."
	end
end
Sensor.orders["sR"] = Sensor.orders["setRelay"]

Sensor.orders["setLED"] = function(sensor,id)
	if id then
		sensor:setLED(id)
		saveObjectsInfo()
		return string.format("Sensors LED has been set to %s.",sensor:getID(),sensor:getLED())
	else
		return "Must supply an ID to set."
	end
end
Sensor.orders["sL"] = Sensor.orders["setLED"]

Sensor.orders["setBuzzer"] = function(sensor,id)
	if id then
		sensor:setBuzzer(id)
		print(id,sensor:getBuzzer())
		saveObjectsInfo()
		return string.format("Sensors buzzer has been set to %s.",sensor:getID(),sensor:getBuzzer())
	else
		return "Must supply an ID to set."
	end
end
Sensor.orders["sBz"] = Sensor.orders["setBuzzer"]

Sensor.orders["setSensitivity"] = function(sensor,amt)
	if id then
		sensor:setSensitivity(amt)
		saveObjectsInfo()
		return string.format("Sensors sensitivity has been set to %s.",sensor:getID(),sensor:getSensitivity())
	else
		return "Must supply an ammount to set."
	end
end
Sensor.orders["sSen"] = Sensor.orders["setSensitivity"]

Sensor.orders["setLightSensitivity"] = function(sensor,amt)
	if id then
		sensor:setLightSensitivity(amt)
		saveObjectsInfo()
		return string.format("Sensors light sensitivity has been set to %s.",sensor:getID(),sensor:getLightSensitivity())
	else
		return "Must supply an ammount to set."
	end
end
Sensor.orders["sLS"] = Sensor.orders["setLightSensitivity"]

Sensor.orders["setTimeOut"] = function(sensor,amt)
	if id then
		sensor:setTimeOut(amt)
		saveObjectsInfo()
		return string.format("Sensors timout has been set to %s.",sensor:getID(),sensor:getTimeOut())
	else
		return "Must supply an ammount to set."
	end
end

Sensor.orders["sTO"] = Sensor.orders["setTimeOut"]



Sensor.orders['sUp'] = function(sensor,amt)
	sensor:setSensitivity(sensor:getSensitivity() + (amt or 5))
	saveObjectsInfo()
	return ("Thermostat Sensitivity now set to %s"):format(sensor:getSensitivity())
end

Sensor.orders['sDown'] = function(sensor,amt)
	sensor:setSensitivity(sensor:getSensitivity() - (amt or 5))
	saveObjectsInfo()
	return ("Thermostat Sensitivity now set to %s"):format(sensor:getSensitivity())
end


Sensor.orders['lsUp'] = function(sensor,amt)
	sensor:setLightSensitivity(sensor:getLightSensitivity() + (amt or 100))
	saveObjectsInfo()
	return ("Thermostat Light Sensitivity now set to %s"):format(sensor:getLightSensitivity())
end

Sensor.orders['lsDown'] = function(sensor,amt)
	sensor:setLightSensitivity(sensor:getLightSensitivity() - (amt or 100))
	saveObjectsInfo()
	return ("Thermostat Light Sensitivity now set to %s"):format(sensor:getLightSensitivity())
end


Sensor.orders['ToUp'] = function(sensor,amt)
	sensor:setTimeOut(sensor:getTimeOut() + (amt or 10))
	saveObjectsInfo()
	return ("Thermostat Time Out now set to %s"):format(sensor:getTimeOut())
end

Sensor.orders['ToDown'] = function(sensor,amt)
	sensor:setTimeOut(sensor:getTimeOut() - (amt or 10))
	saveObjectsInfo()
	return ("Thermostat Time Out threshold now set to %s"):format(sensor:getTimeOut())
end



return Sensor
