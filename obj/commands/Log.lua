local Command	= require("obj.Command")

--- log command
local Log	= Command:clone()
Log.name = "Log"
Log.keywords	= {"log"}

--- Execute the command
function Log:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]

	if input2 then
		if Log.orders[input2] then--This is a valid order
			return Log.orders[input2](input3,user)
		else
			return "That is not a vaild order."
		end
	else
		pollSensors(true,true)
		local msg = getStatus()
		if par == "mail" then
			sendMessage("Status", msg ,user)
		elseif par == "tcp" then
			user:send(msg)
		end
	end
	return false
end

Log.orders = {}
Log.orders['update'] = function(input3,user)
	for i,v in ipairs(nodes) do
		if v.sensors then v:send('Request SenTemp') end
		if v.lightsensors then v:send('Request SenLight') end
	end
end
Log.orders['on'] = function()

end
Log.orders['off'] = function()

end

return Log
