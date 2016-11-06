local Command	= require("obj.Command")

--- Ping command
local Ping		= Command:clone()
Ping.name = "Ping"
Ping.keywords	= {"PING"}

--- Execute the command
function Ping:execute(input,user,par)
	if par == 'tcp' then
		user:send('PONG')
	end
	return false
end

return Ping
