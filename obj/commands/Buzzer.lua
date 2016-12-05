local Command	= require("obj.Command")

--- test command
local Buzzer	= Command:clone()
Buzzer.name = "Buzzer"
Buzzer.keywords	= {"B","Buzzer","Buzz"}

--- Execute the command
function Buzzer:execute(input,user)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then--input2 should be the id(pin) or index of a Buzzer
		local buzzer = buzzers[input2] or buzzers[tonumber(input2)] or buzzerPins[tonumber(input2)] and buzzers[buzzerPins[tonumber(input2)]]
		if buzzer then --That is a vaild Buzzer
			if input3 then--input3 should be the order to execute
				if Buzzer.orders[input3] then--This is a valid order
					return Buzzer.orders[input3](buzzer,input4,input5)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild buzzer."
		end
	else
		return "Please select a buzzer when issuing a buzzer command"
	end
end

Buzzer.orders = {}
Buzzer.orders["rename"] = function(buzzer,name)
	if name then
		buzzer:setName(name)
		saveObjectsInfo()
		return string.format("Buzzer %s has been renamed %s.",buzzer:getID(),buzzer:getName())
	else
		return "Must supply a name to rename a buzzer."
	end
end
--[[Buzzer.orders["play"] = function(buzzer,tune)
	if tune then
		Scheduler:queue(Event:new(function() buzzer:play(tune) end, 3, false))
		return string.format("Buzzer %s is playing tune %s.",buzzer:getID(),tune)
	else
		return "Must supply a tune number 1-5 to play."
	end
end]]

Buzzer.orders["test"] = function(buzzer,num,leng)
	buzzer:test()
end

Buzzer.orders["stop"] = function(buzzer)
	buzzer:off()
	buzzer.stayOff = socket.gettime() + 10000
	return string.format("%s is stopped!",buzzer:getName())
end

Buzzer.orders["on"] = function(buzzer,f,multiplier)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local on = f and buzzer:forceOn(f) or buzzer:on()
	if on then
		return string.format("%s is now on%s.",buzzer:getName(),f and " for "..f.." seconds" or "")
	elseif buzzer.stayOff then
		return string.format("%s is off for %s more seconds.",buzzer:getName(), math.round(buzzer.stayOff - socket.gettime()))
	else
		return string.format("%s is already on%s.",buzzer:getName(),f and " and will stay on for "..f.." seconds" or "")
	end
end
Buzzer.orders["off"] = function(buzzer,f,multiplier)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local off = f and buzzer:forceOff(f) or buzzer:off()
	if off then
		return string.format("%s is now off%s.",buzzer:getName(),f and " for "..f.." seconds" or "")
	elseif buzzer.stayOn then
		return string.format("%s is off for %s more seconds.",buzzer:getName(), math.round(buzzer.stayOn - socket.gettime()))
	else
		return string.format("%s is already off%s.",buzzer:getName(),f and " and will stay off for "..f.." seconds" or "")
	end
end

return Buzzer
