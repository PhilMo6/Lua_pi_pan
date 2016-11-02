local Command	= require("obj.Command")

--- Ping command
local Ping		= Command:clone()
Ping.name = "Ping"
Ping.keywords	= {"PING"}

--- Execute the command
function Ping:execute(input,user,par)
	return "PONG"
end

return Ping
