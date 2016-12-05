local Command	= require("obj.Command")

--- test command
local Motor	= Command:clone()
Motor.name = "Motor"
Motor.keywords	= {"motor","mot","Mot"}

--- Execute the command
function Motor:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a Motor
		local motor = motors[input2] or motors[tonumber(input2)]
		if motor then --That is a vaild Motor
			if input3 then--input3 should be the order to execute
				if Motor.orders[input3] then--This is a valid order
					return Motor.orders[input3](motor,input4,input5,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Stepper Motor."
		end
	else
		return "Please select a Stepper Motor when issuing a Stepper Motor command"
	end
end

Motor.orders = {}
Motor.orders["rename"] = function(motor,name)
	if name then
		motor:setName(name)
		saveObjectsInfo()
		return string.format("Stepper Motor %s has been renamed %s.",motor:getID(),motor:getName())
	else
		return "Must supply a name to rename a Stepper Motor."
	end
end
Motor.orders["re"] = Motor.orders["rename"]
Motor.orders["read"] = function(motor)
	local r1 = motor:getDirection()()
	return string.format("%s is %s",motor:getName(),r1)
end
Motor.orders["r"] = Motor.orders["read"]


Motor.orders["off"] = function(motor)
	local stoped = motor:stop()
	if stoped then
		return string.format("%s is now stopped.",motor:getName())
	end
end
Motor.orders["stop"] = Motor.orders["off"]



Motor.orders["forward"] = function(motor)
	motor:stop(true)
	local forw = motor:forward()
	if forw then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
Motor.orders["for"] = Motor.orders["forward"]

Motor.orders["reverse"] = function(motor)
	motor:stop(true)
	local rev = motor:reverse()
	if rev then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
Motor.orders["rev"] = Motor.orders["reverse"]

Motor.orders["setSpeed"] = function(motor,v1,v2)
	local set = motor:setSpeed(v1,v2)
	if set then
		return string.format("speed now set to %s %s.",v1,v2)
	end
end
Motor.orders["ss"] = Motor.orders["setSpeed"]

Motor.orders["test"] = function(motor,_,_,user)
	motor:test()
end

return Motor
