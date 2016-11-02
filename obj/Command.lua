

local Cloneable	= require("obj.Cloneable")

--- Cloneable that is used to handle text commands.
local Command	= Cloneable.clone()
Command.name 	= "Command"
Command.keywords	= {}

--- Execute the command
function Command:execute(input,user)
end

return Command
