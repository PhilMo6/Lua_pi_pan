local Command	= require("obj.Command")

--- test command
local Feeder	= Command:clone()
Feeder.name = "Feeder"
Feeder.keywords	= {"Feeder","feed","fe"}

--- Execute the command
function Feeder:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a Feeder
		local feeder = feeders[input2] or feeders[tonumber(input2)]
		if feeder then --That is a vaild Feeder
			if input3 then--input3 should be the order to execute
				if Feeder.orders[input3] then--This is a valid order
					return Feeder.orders[input3](feeder,input4,input5,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Stepper Feeder."
		end
	else
		return "Please select a Stepper Feeder when issuing a Stepper Feeder command"
	end
end

Feeder.orders = {}

Feeder.orders["setCount"] = function(feeder,value)
	if value then
		feeder:setCount(value)
		saveObjectsInfo()
		return string.format("Feeder %s has had its count set to %s.",feeder:getID(),feeder:getCount())
	else
		return "Must supply a value to set count on feeder."
	end
end

Feeder.orders["setStepper"] = function(feeder,stepperID)
	if stepperID then
		feeder:setStepper(stepperID)
		saveObjectsInfo()
		return string.format("Feeder %s has had its stepper set to %s.",feeder:getID(),feeder:getStepper())
	else
		return "Must supply a stepper id to set stepper on feeder."
	end
end

Feeder.orders["rename"] = function(feeder,name)
	if name then
		feeder:setName(name)
		saveObjectsInfo()
		return string.format("Feeder %s has been renamed %s.",feeder:getID(),feeder:getName())
	else
		return "Must supply a name to rename a Feeder."
	end
end
Feeder.orders["re"] = Feeder.orders["rename"]

Feeder.orders["test"] = function(feeder)
	feeder:test()
end

return Feeder
