local Command	= require("obj.Command")

--- Pong command
local Pong		= Command:clone()
Pong.name = "Pong"
Pong.keywords	= {"PONG"}

--- Execute the command
function Pong:execute(input,user,par)
	if par == 'tcp' then
		if runningServer then runningServer:pong(user) end
	end
	return false
end

return Pong
