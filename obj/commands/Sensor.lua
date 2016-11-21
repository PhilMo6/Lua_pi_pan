local Command	= require("obj.Command")

--- test command
local Sensor	= Command:clone()
Sensor.name = "Sensor"
Sensor.keywords	= {"sensor","sen","s","S"}

--- Execute the command
function Sensor:execute(input,user)
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]

	if input2 then--input2 should be the id or index of a sensor
		local sensor = sensors[input2] or sensors[tonumber(input2)] or lightsensors and (lightsensors[input2] or lightsensors[tonumber(input2)]) or DHT22s and (DHT22s[input2] or DHT22s[tonumber(input2)])
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
		updateSensorNames()
		return string.format("Sensor %s has been renamed %s.",sensor:getID(),sensor:getName())
	else
		return "Must supply a name to rename a sensor."
	end
end
Sensor.orders["re"] = Sensor.orders["rename"]
Sensor.orders["read"] = function(sensor)
	local r1,r2,er = sensor:read()
	return string.format("%s %s",sensor:getName(),(not er and r1 .. (r2 and "  " ..r2 or "") or er))
end
Sensor.orders["r"] = Sensor.orders["read"]
Sensor.orders["lastread"] = function(sensor)
	local r1,r2 = sensor:getLastRead()
	return string.format("%s %s",sensor:getName(), r1 .. (r2 and "  " ..r2 or ""))
end
Sensor.orders["lr"] = Sensor.orders["lastread"]


return Sensor
