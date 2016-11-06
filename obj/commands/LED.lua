local Command	= require("obj.Command")

--- test command
local LED	= Command:clone()
LED.name = "LED"
LED.keywords	= {"L","led","l"}

--- Execute the command
function LED:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a LED
		local led = LEDs[input2] or LEDs[tonumber(input2)] or LEDPins[tonumber(input2)] and LEDs[LEDPins[tonumber(input2)]]
		if led then --That is a vaild LED
			if input3 then--input3 should be the order to execute
				if LED.orders[input3] then--This is a valid order
					return LED.orders[input3](led,input4,input5,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild LED."
		end
	else
		return "Please select a LED when issuing a LED command"
	end
end

LED.orders = {}
LED.orders["rename"] = function(led,name)
	if name then
		led:setName(name)
		updateLEDNames()
		return string.format("LED %s has been renamed %s.",led:getID(),led:getName())
	else
		return "Must supply a name to rename a LED."
	end
end
LED.orders["re"] = LED.orders["rename"]
LED.orders["read"] = function(led)
	local r1 = led:read()
	return string.format("%s is %s",led:getName(),r1)
end
LED.orders["r"] = LED.orders["read"]

LED.orders["on"] = function(led,f,multiplier,user)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local on = f and led:forceOn(f) or led:on(user)
	if on then
		return string.format("%s is now on%s.",led:getName(),f and " for "..f.." seconds" or "")
	elseif led.stayOff then
		return string.format("%s is off for %s more seconds.",led:getName(), math.round(led.stayOff - socket.gettime()))
	else
		return string.format("%s is already on%s.",led:getName(),f and " and will stay on for "..f.." seconds" or "")
	end
end
LED.orders["off"] = function(led,f,multiplier,user)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local off = f and led:forceOff(f) or led:off(user)
	if off then
		return string.format("%s is now off%s.",led:getName(),f and " for "..f.." seconds" or "")
	elseif led.stayOn then
		return string.format("%s is off for %s more seconds.",led:getName(), math.round(led.stayOn - socket.gettime()))
	else
		return string.format("%s is already off%s.",led:getName(),f and " and will stay off for "..f.." seconds" or "")
	end
end

LED.orders["test"] = function(led,com,_,user)
	led:test(com,user)
end

LED.orders["blink"] = function(led,dir,count)
	led:blink(dir,count,user)
end

return LED
