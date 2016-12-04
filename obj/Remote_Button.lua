local Cloneable			= require("obj.Remote_Common")
local Button			= Cloneable:clone()
--[[
	Remote object for buttons/switchs/motion sensors attached to nodes.
	Node will update the button whenever a press is detected.
	A press can be simulated with the press function and will be pushed to node.
]]

Button.location = 'buttons'
Button.states = {
	[0]='released'
	[1]='open',
	[2]='pressed',
	[3]='held',
}

function Button:press(f,client)
	if not self.pressed then
		self.read = function()
			self.read = Button.read
			self.pressed = nil
			return true end
		if self.masters then
			for i,v in ipairs(self.masters) do
				if client and v ~= client.master or not client then v:send(([[button %s_%s press]]):format(self:getName(),mainID)) end
			end
		end
		if self.node then
			if client and self.node ~= client.node or not client then self.node:send(([[button %s press]]):format(self:getID())) end
		end
		self.pressed = true
		return true
	end
	return false
end

--- Stringifier for Cloneables.
function Button:toString()
	return string.format("[Remote_Button] %s %s %s",self:getID(),self:getName(),(self:read() == true and 'pressed' or 'not pressed'))
end

return Button
