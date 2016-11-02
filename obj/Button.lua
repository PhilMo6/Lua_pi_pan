local Cloneable			= require("obj.baseObj")
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
		GPIO.setup{
		   channel=pin,
		   direction=GPIO.IN,
		   pull_up_down = GPIO.PUD_DOWN,
		}
	end
end

function Button:getHTMLcontrol()
	return ('%s'):format(
	([[<button onclick="myFunction('button %s press')">Press</button >]]):format(self:getName())
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

function Button:readO()
	local r = GPIO.input(self:getID())
	if self.lastRead ~= r and r == true then
		if self.lastRead ~= nil then logEvent(self:getName(),self:getName() .. ' readO:true') end
		if self.masters then
			for i,v in ipairs(self.masters) do
				v:send(([[button %s_%s press]]):format(self:getName(),mainID))
			end
		end
	elseif self.lastRead ~= r and r == false and self.lastRead ~= nil then
		logEvent(self:getName(),self:getName() .. ' readO:false')
	end
	self.lastRead = r
	return self.lastRead
end

function Button:press(f,client)
	if client and client.master then client = client.master end
	if not self.pressed then
		self.readO = function()
			self.readO = Cloneable.readO
			self.lastRead = nil
			self.pressed = nil
			logEvent(self:getName(),self:getName() .. ' press:pressed')
			if self.masters then
				for i,v in ipairs(self.masters) do
					if v ~= client then v:send(([[button %s_%s press]]):format(self:getName(),mainID)) end
				end
			end
			return true end
		self.pressed = true
		return true
	end
	return false
end


--- Stringifier for Cloneables.
function Button:toString()
	return string.format("[Button] %s %s %s",self:getID(),self:getName(),(self:readO() == true and 'pressed' or 'not pressed'))
end

return Button
