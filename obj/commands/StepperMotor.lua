local Command	= require("obj.Command")

--- test command
local StepperMotor	= Command:clone()
StepperMotor.name = "StepperMotor"
StepperMotor.keywords	= {"Stm","Stepper","stepper","Step","step"}

--- Execute the command
function StepperMotor:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a StepperMotor
		local motor = stepperMotors[input2] or stepperMotors[tonumber(input2)]
		if motor then --That is a vaild StepperMotor
			if input3 then--input3 should be the order to execute
				if StepperMotor.orders[input3] then--This is a valid order
					return StepperMotor.orders[input3](motor,input4,input5,par == 'tcp' and user or nil)
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

StepperMotor.orders = {}
StepperMotor.orders["rename"] = function(motor,name)
	if name then
		motor:setName(name)
		saveObjectsInfo()
		return string.format("Stepper Motor %s has been renamed %s.",motor:getID(),motor:getName())
	else
		return "Must supply a name to rename a Stepper Motor."
	end
end
StepperMotor.orders["re"] = StepperMotor.orders["rename"]
StepperMotor.orders["read"] = function(motor)
	local r1 = motor:getDirection()()
	return string.format("%s is %s",motor:getName(),r1)
end
StepperMotor.orders["r"] = StepperMotor.orders["read"]

StepperMotor.orders["on"] = function()
	return string.format("Use the forward or backward commands to step motor.",motor:getName())
end

StepperMotor.orders["off"] = function(motor)
	local off = motor:off()
	if off then
		return string.format("%s is now off.",motor:getName())
	end
end

StepperMotor.orders["forward"] = function(motor,count)
	motor:off(true)
	local step = motor:stepF(tonumber(count or 1000))
	if step then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
StepperMotor.orders["f"] = StepperMotor.orders["forward"]

StepperMotor.orders["backward"] = function(motor,count)
	motor:off(true)
	local step = motor:stepB(tonumber(count or 1000))
	if step then
		return string.format("%s is now going %s.",motor:getName(),motor:getDirection())
	end
end
StepperMotor.orders["b"] = StepperMotor.orders["backward"]

StepperMotor.orders["setSpeed"] = function(motor,v)
	local set = motor:setSpeed(v)
	if set then
		return string.format("speed now set to %s.",motor:getSpeed())
	end
end
StepperMotor.orders["ss"] = StepperMotor.orders["setSpeed"]

StepperMotor.orders["test"] = function(motor,_,_,user)
	motor:test()
end

return StepperMotor
