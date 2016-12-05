local Command	= require("obj.Command")

--- test command
local Object	= Command:clone()
Object.name = "Object"
Object.keywords	= {"object","Obj","obj","o"}

--- Execute the command
function Object:execute(input,user)
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]

	if input2 then--input2 should be the id of a Object
		local obj = objectIDs
		if obj then --That is a vaild Object
			if input3 then--input3 should be the order to execute
				if Object.orders[input3] then--This is a valid order
					return Object.orders[input3](obj,input4)
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

return Object
