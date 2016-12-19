local Command	= require("obj.Command")

--- test command
local Object	= Command:clone()
Object.name = "Object"
Object.keywords	= {"object","Obj","obj","o"}

--- Execute the command
function Object:execute(input,user)
	local words = string.Words(input)
	local command,objID,order,arg1,arg2 = words[1],words[2],words[3],words[4],words[5]

	if objID then--input2 should be the id of a Object
		local obj = objectIDs[objID]
		if obj then --That is a vaild Object
			if order then--input3 should be the order to execute
				if Object.orders[order] then--This is a valid order
					return Object.orders[order](obj,arg1,arg2,user)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild object."
		end
	else
		return "Please select a object when issuing a object command"
	end
end

Object.orders = {}
Object.orders["rename"] = function(obj,name)
	if name then
		obj:setName(name)
		objectUpdate()
		return string.format("Object %s has been renamed %s.",obj:getID(),obj:getName())
	else
		return "Must supply a name to rename a Object."
	end
end
Object.orders["re"] = Object.orders["rename"]

Object.orders["read"] = function(obj)
	if obj.read then
		local r1 = obj:read()
		return string.format("%s is %s",obj:getName(),r1)
	else
		return 'This object cannot be read...'
	end
end
Object.orders["r"] = Object.orders["read"]

Object.orders["on"] = function(obj,f,multiplier,user)
print('!!!!!!!!!!!!!!!!!!',obj, obj.on)
	if obj.on then
		if f then
			f = tonumber(f)
			if multiplier then f = timeM(f,multiplier) end
		end
		local on = f and obj.forceOn and obj:forceOn(f,user) or obj:on(user)
		if on then
			return string.format("%s is now on%s.",obj:getName(),f and " for "..f.." seconds" or "")
		elseif obj.stayOff then
			return string.format("%s is off for %s more seconds.",obj:getName(), math.round(obj.stayOff - socket.gettime()))
		else
			return string.format("%s is already on%s.",obj:getName(),f and " and will stay on for "..f.." seconds" or "")
		end
	else
		return 'This object cannot be turned on...'
	end
end
Object.orders["off"] = function(obj,f,multiplier,user)
	if obj.off then
		if f then
			f = tonumber(f)
			if multiplier then f = timeM(f,multiplier) end
		end
		local off = f and obj.forceOff and Object:forceOff(f) or Object:off(user)
		if off then
			return string.format("%s is now off%s.",obj:getName(),f and " for "..f.." seconds" or "")
		elseif Object.stayOn then
			return string.format("%s is off for %s more seconds.",obj:getName(), math.round(obj.stayOn - socket.gettime()))
		else
			return string.format("%s is already off%s.",obj:getName(),f and " and will stay off for "..f.." seconds" or "")
		end
	else
		return 'This object cannot be turned off...'
	end
end
Object.orders["toggle"] = function(obj,_,_,user)
	if obj.toggle then obj:toggle(user) end
end

Object.orders["test"] = function(obj,com,_,user)
	if obj.test then obj:test(com,user) end
end

return Object
