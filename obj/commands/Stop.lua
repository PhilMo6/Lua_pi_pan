local Command	= require("obj.Command")

--- test command
local Stop		= Command:clone()
Stop.name = "Stop"
Stop.keywords	= {"stop","Quit","quit"}

--- Execute the command
function Stop:execute(input,user)
	local words = string.Words(input)
	local input1, input2 = words[1],words[2]

	if input2 == "restart" or input2 == "re" then _G.RESET = true elseif input2 == "reboot" then _G.REBOOT = true end
	run = false

	return 'GHC shutting down'

end

return Stop
