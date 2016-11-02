--[[
	Command parser used to run commands recived though tcp or email/sms.
	Will be adding functionality for other forms of communication in the future.
	All commands are stored in obj/commands folder and are automaticly added to the
	parsers command list when the parser loads.
]]

local CommandParser = {}
--- List of all commands we recognized.
CommandParser.commands	= {}

function CommandParser:leglizeInput(input)
	input = string.gsub(input,'[%%%^%$%\\%<%>]','')
	--input = string.gsub(input,'[%]%[%(%)%.%%%+%-%*%?%^%$]','')
	return input
end

--- Parses command input
function CommandParser:parse(input,user,parser)
	input = CommandParser:leglizeInput(input)
	local word = string.getWord(input)
	if CommandParser.commands[word] ~= nil then
		local re = CommandParser.commands[word]:execute(input,user,parser)
		return true,re,CommandParser.commands[word]
	end
	return false
end

--- Adds a Command to the list of commands we recognize.
-- @param command Command to be added.
function CommandParser:addCommand(command)
	if not CommandParser.commands[command.name] then
		table.insert(CommandParser.commands, command)
		CommandParser.commands[command.name] = command
		for i,v in pairs(command.keywords) do
			CommandParser.commands[v] = command
		end
	end
end

for i,v in ipairs(scandir("/obj/commands")) do
	if v ~= "." and v ~= ".." then
		local file = string.match(v, "(.+)%.lua")
		if file then -- it's an lua file!
			local package = string.format("obj.commands.%s", file)
			local command = require(package)
			CommandParser:addCommand(command:new())
		end
	end
end

_G.CommandParser = CommandParser
return CommandParser
