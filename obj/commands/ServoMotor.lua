local Command	= require("obj.Command")

--- test command
local ServoMotor	= Command:clone()
ServoMotor.name = "ServoMotor"
ServoMotor.keywords	= {"servomotor","Stm","Servo","servo","Ser","ser"}

--- Execute the command
function ServoMotor:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a ServoMotor
		local motor = servoMotors[input2] or servoMotors[tonumber(input2)]
		if motor then --That is a vaild ServoMotor
			if input3 then--input3 should be the order to execute
				if ServoMotor.orders[input3] then--This is a valid order
					return ServoMotor.orders[input3](motor,input4,input5,par == 'tcp' and user or nil)
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

ServoMotor.orders = {}
ServoMotor.orders["rename"] = function(motor,name)
	if name then
		motor:setName(name)
		updateServoMotorinfo()
		return string.format("Stepper Motor %s has been renamed %s.",motor:getID(),motor:getName())
	else
		return "Must supply a name to rename a Stepper Motor."
	end
end
ServoMotor.orders["re"] = ServoMotor.orders["rename"]
ServoMotor.orders["read"] = function(motor)
	local r1 = motor:getDirection()()
	return string.format("%s is %s",motor:getName(),r1)
end
ServoMotor.orders["r"] = ServoMotor.orders["read"]

ServoMotor.orders["middle"] = function()
	return string.format("Use the forward or backward commands to step motor.",motor:getName())
end

ServoMotor.orders["forward"] = function(motor,count)
	motor:off(true)
	local step = motor:stepF(tonumber(count or 1000))
	if step then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
ServoMotor.orders["f"] = ServoMotor.orders["forward"]

ServoMotor.orders["backward"] = function(motor,count)
	motor:off(true)
	local step = motor:stepB(tonumber(count or 1000))
	if step then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
ServoMotor.orders["b"] = ServoMotor.orders["backward"]

ServoMotor.orders["test"] = function(motor,_,_,user)
	motor:test()
end

return ServoMotor
