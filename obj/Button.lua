local Cloneable			= require("obj.Common")
local Button			= Cloneable:clone()

--[[
	This is the base button object used for buttons, switchs, motion sensors, ext..
	A press can be simulated with the press function.
]]

function Button:initialize(pin)
	if not _G.buttons then  _G.buttons = {name='buttons'} _G.buttonIDs ={} table.insert(objects,buttons) objects["buttons"] = buttons end
	if not buttons['Button_'..pin] then
		self.config = {}
		self:setID(pin)
		self:setName('Button_'..pin)
		table.insert(buttons,self)
		self.gpio = RPIO(pin)
		self.gpio:set_direction('in')
	end
end

function Button:getHTMLcontrol()
	local name = self:getName()
	return ([[%s %s <form id="%s"><input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('button %s press')">Press</button >]]):format(name),
	([[<button onclick="myFunction('s %s re','%s')">Rename</button >]]):format(name,name),
	name
	)
end

function Button:setID(id)
	if self.config.id then buttonIDs[self.config.id] = nil logEvent(self:getName(),self:getName() .. ' setID:'..id ) end
	self.config.id = id
	buttonIDs[self.config.id] = self
end

function Button:setName(name)
	if self.config.name then buttons[self.config.name] = nil logEvent(self:getName(),self:getName() .. ' setName:'..name ) end
	self.config.name = name
	buttons[self.config.name] = self
end

function Button:read()
	local r = self.gpio:read()
	if self.lastRead ~= r and r == 0 then
		if self.lastRead ~= nil then logEvent(self:getName(),self:getName() .. ' read:1') end
		if self.masters then
			for i,v in ipairs(self.masters) do
				v:send(([[button %s_%s press]]):format(self:getName(),mainID))
			end
		end
	elseif self.lastRead ~= r and r == 1 and self.lastRead ~= nil then
		logEvent(self:getName(),self:getName() .. ' read:0')
	end
	self.lastRead = r
	return self.lastRead
end

function Button:press(f,client)
	if client and client.master then client = client.master end
	if not self.pressed then
		self.read = function()
			self.read = Cloneable.read
			self.lastRead = nil
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
