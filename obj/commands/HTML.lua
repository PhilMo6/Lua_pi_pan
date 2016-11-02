local Command	= require("obj.Command")

--- test command
local HTML	= Command:clone()
HTML.name = "HTML"
HTML.keywords	= {"html"}

--- Execute the command
function HTML:execute(input,user,par)
	if par == 'tcp' then
		local words = string.Words(input)
		local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]
		if HTML.orders[input2] then--This is a valid order
			return HTML.orders[input2](input3,user)
		else
			return "That is not a vaild order."
		end
	end
	return false
end

HTML.orders = {}
HTML.orders["controls"] = function()
	return HTMLcontrols()
end
HTML.orders["controls2"] = function(id)
	return HTMLcontrols2(id)
end

HTML.orders["MSR"] = function(id)
	if id then
		return removeSensorLink(id)
	else
		return 'must supply ID to remove sensor from MasterSensors table'
	end
end


return HTML
