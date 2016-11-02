local Command	= require("obj.Command")

--- test command
local Test		= Command:clone()
Test.name = "Test"
Test.keywords	= {"test"}

--- Execute the command
function Test:execute(input,user)
	print('test')
end

return Test
