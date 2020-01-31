local Command	= require("obj.Command")

--- test command
local Relay	= Command:clone()
Relay.name = "Relay"
Relay.keywords	= {"Relay","Rel","R","relay","rel","r"}

--- Execute the command
function Relay:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]
	if input2 then--input2 should be the id(pin) or index of a Relay
		local relay = relays[input2] or relays[tonumber(input2)] or relayPins[tonumber(input2)] and relays[relayPins[tonumber(input2)]]
		if relay then --That is a vaild Relay
			if input3 then--input3 should be the order to execute
				if Relay.orders[input3] then--This is a valid order
					return Relay.orders[input3](relay,input4,input5,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Relay."
		end
	else
		return "Please select a Relay when issuing a Relay command"
	end
end

Relay.orders = {}
Relay.orders["rename"] = function(relay,name,void,user)
	if name then
		relay:setName(name)
		saveObjectsInfo()
		return string.format("Relay %s has been renamed %s.",relay:getID(),relay:getName())
	else
		return "Must supply a name to rename a Relay."
	end
end
Relay.orders["re"] = Relay.orders["rename"]
Relay.orders["read"] = function(relay)
	local r1 = relay:read()
	return string.format("%s is %s",relay:getName(),r1 == 1 and 'off' or 'on')
end
Relay.orders["r"] = Relay.orders["read"]

Relay.orders["on"] = function(relay,f,multiplier,user)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local on = f and relay:forceOn(f) or relay:on(user)
	if on then
		return string.format("%s is now on%s.",relay:getName(),f and " for "..f.." seconds" or "")
	elseif relay.stayOff then
		return string.format("%s is off for %s more seconds.",relay:getName(), math.round(relay.stayOff - socket.gettime()))
	else
		return string.format("%s is already on%s.",relay:getName(),f and " and will stay on for "..f.." seconds" or "")
	end
end
Relay.orders["off"] = function(relay,f,multiplier,user)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	end
	local off = f and relay:forceOff(f) or relay:off(user)
	if off then
		return string.format("%s is now off%s.",relay:getName(),f and " for "..f.." seconds" or "")
	elseif relay.stayOn then
		return string.format("%s is on for %s more seconds.",relay:getName(), math.round(relay.stayOn - socket.gettime()))
	else
		return string.format("%s is already off%s.",relay:getName(),f and " and will stay off for "..f.." seconds" or "")
	end
end

Relay.orders["toggle"] = function(relay,void,void2,user)
	relay:toggle(user)
end

Relay.orders["timer"] = function(relay,f,multiplier,user)
	if f then
		f = tonumber(f)
		if multiplier then f = timeM(f,multiplier) end
	else 
		f = 5
	end
	local on = relay:timerOn(f)
	if on then
		return string.format("%s is now on%s.",relay:getName()," for "..f.." seconds")
	elseif relay.stayOff then
		return string.format("%s is off for %s more seconds.",relay:getName(), math.round(relay.stayOff - socket.gettime()))
	else
		return string.format("%s is already on.",relay:getName())
	end
end

return Relay
