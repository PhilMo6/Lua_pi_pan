local Command	= require("obj.Command")

--- test command
local Node	= Command:clone()
Node.name = "Node"
Node.keywords	= {}

--- Execute the command
function Node:execute(input,user,par)
	if par == "tcp" then
		if user.node or user.master then
			return Request:subexecute(input,user,par)
		end
	end
	return false
end

function Node:subexecute(input,user,par)
	if input2 then--input2 should be the index of a Node
		local node = nodes[input2]
		if node then --That is a vaild Node
			if input3 then--input3 should be the order to execute
				if Node.orders[input3] then--This is a valid order
					return Node.orders[input3](node,input4,input5,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Node."
		end
	else
		return "Please select a Node when issuing a Node command"
	end
	return false
end


Node.orders = {}
Node.orders["stop"] = function(node,re)
	if re then re = 'restart' end
	node:send('stop ' .. (re or ''))
	return node:toString() .. ' stopping ' .. (re and 'restarting' or '')
end


return Node
