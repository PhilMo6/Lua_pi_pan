local Cloneable			= require("obj.Button")
local Button			= Cloneable:clone()
--[[
	Remote object for buttons/switchs/motion sensors attached to nodes.
	Node will update the button whenever a press is detected.
	A press can be simulated with the press function and will be pushed to node.
]]

function Button:initialize(id,name,node)
	if not _G.buttons then _G.buttons = {name='buttons'} table.insert(objects,buttons) objects["buttons"] = buttons end
	if not buttons[name..'_'..node:getID()] then
		self.config = {}
		self:setID(id)
		self:setName(name..'_'..node:getID())
		table.insert(buttons,self)
		node:addButton(self)
	end
end

function Button:removeButton()
	buttons[self:getName()] = nil
	while table.removeValue(buttons, self) do end
	if self.node then local node=self.node self.node=nil node:removeButton(buttons) end
end

function Button:getHTMLcontrol()
	return ('%s'):format(
	([[<button onclick="myFunction('button %s press')">Press</button >]]):format(self:getName())
	)
end

function Button:setID(id)
	self.config.id = id
end

function Button:setName(name)
	if self.config.name then buttons[self.config.name] = nil end
	self.config.name = name
	buttons[self.config.name] = self
end

function Button:read()
	return false
end

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
