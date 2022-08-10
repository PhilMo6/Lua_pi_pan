local Command	= require("obj.Command")

--- Status command
local Status		= Command:clone()
Status.name = "Status"
Status.keywords	= {"status","stat","Stat"}

--- Execute the command
function Status:execute(input,user,parser)
	local msg = getStatus()
	if parser == "mail" then
		sendEmail("Status", msg ,user)
	elseif parser == "tcp" then
		user:send(msg)
	end
	return false
end

return Status
