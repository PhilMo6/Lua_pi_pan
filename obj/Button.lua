local Cloneable			= require("obj.Common")
local Button			= Cloneable:clone()

--[[
	This is the base button object used for buttons, switchs, motion sensors, ext..
	A press can be simulated with the press function.
]]

Button.location = 'buttons'
Button.states = {
	[0]='released'
	[1]='open',
	[2]='pressed',
	[3]='held',
}

function Button:setup(options)
	local pin,edge = options.pin,options.edge
	self.gpio = RPIO(pin)
	self.gpio:set_direction('in')
	self.config.pin = pin
	self.config.edge = edge
end

function Button:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('button %s press')">Press</button >]]):format(name),
	([[<button onclick="myFunction('s %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end

function Button:nextState()
	if Button.states[self.config.state + 1] then self.config.state = self.config.state + 1 logEvent(self:getName(),self:getName() .. ' '..self:getState()) self:updateMasters() end
end

function Button:resetState()
	if self.config.state > 1 then
		self.config.state = 0
		logEvent(self:getName(),self:getName() .. ' '..self:getState()
	elseif self.config.state ~= 1 then
		self.config.state = 1
		logEvent(self:getName(),self:getName() .. ' '..self:getState()
	end
end

function Button:getState()
	return Button.states[self.config.state]
end

function Button:read()
	local r = self.gpio:read()
	if r == self.config.edge then
		self:nextState()
	elseif r ~= self.config.edge then
		self:resetState()
	end
	self:updateLastRead(r)
	return self:getLastRead()
end

function Button:press(f,client)
	if client and client.master then client = client.master end
	if not self.pressed then
		self.read = function()
			self.read = Button.read
			self.config.lastRead = self.config.edge == 0 and 1 or 0
			self.pressed = nil
			logEvent(self:getName(),self:getName() .. ' press:pressed')
			if self.masters then
				for i,v in ipairs(self.masters) do
					if v ~= client then v:send(([[button %s_%s press]]):format(self:getName(),mainID)) end
				end
			end
			return 0 end
		self.pressed = true
		return true
	end
	return false
end


--- Stringifier for Cloneables.
function Button:toString()
	local r = self:read()
	return string.format("[Button] %s %s %s",self:getID(),self:getName(),r)
end

return Button
