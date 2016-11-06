local Cloneable			= require("obj.LED")
local LED			= Cloneable:clone()
--[[
	Remote object for 1 color LEDs attached to nodes.
	Node will update the LED whenever change is detected.
]]

function LED:initialize(id,name,node)
	if not _G.LEDs then _G.LEDs = {name='LEDs'} table.insert(objects,LEDs) objects["LEDs"] = LEDs end
	if not LEDs[name..'_'..node:getID()] then
		self.config = {}
		self:setID(id)
		self:setName(name..'_'..node:getID())
		node:addLED(self)
		table.insert(LEDs,self)
	end
end

function LED:removeLED()
	LEDs[self:getName()] = nil
	while table.removeValue(LEDs, self) do end
	if self.node then local node=self.node self.node=nil node:removeLED(self) end
end

function LED:updateLastRead(v)
	local lastread = self.lastRead
	self.lastRead = v
	if self.masters and lastread ~= self.lastRead then
		self:updateMasters()
	end
end

function LED:getHTMLcontrol()
	return ('%s %s %s'):format(
	([[<button onclick="myFunction('L %s on')">On</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s off')">Off</button >]]):format(self:getName()),
	([[<button onclick="myFunction('L %s test')">Test</button >]]):format(self:getName())
	)
end

function LED:setID(id)
	if self.config.id then
		if self.node then
			self.node.LEDs[self.config.id] = nil
			self.node.LEDs[id] = self
		end
	end
	self.config.id = id
end

function LED:setName(name)
	if self.config.name then
		LEDs[self.config.name] = nil
		if self.node then
			self.node:send(([[LED %s rename %s]]):format(self:getID(),name))
			self.node.LEDs[self.config.name] = nil
			self.node.LEDs[name] = self
		end
	end
	self.config.name = name
	LEDs[self.config.name] = self
end


function LED:blink(dir,count,client)
	if not self.blinking then
		self.node:send(([[LED %s blink %s %s]]):format(self:getID(),dir or "",count or ""))
		if self.masters then
			self:updateMasters()
		end
	end
	return false
end

function LED:test()
	if self.node then self.node:send(([[LED %s test]]):format(self:getID())) end
end

function LED:toggle(client)
	if self:read() == 0 then
		self:on(client)
		return 'on'
	else
		self:off(client)
		return 'off'
	end
end

function LED:off(client)
	if self:read() == 1 and not self.stayOn then
		if client and self.node ~= client.node or not client then self.node:send(([[LED %s off]]):format(self:getID())) end
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:on(client)
	if self:read() == 0 and not self.stayOff then
		if client and self.node ~= client.node or not client then self.node:send(([[LED %s on]]):format(self:getID())) end
		if self.masters then
			self:updateMasters()
		end
		return true
	end
	return false
end

function LED:read()
	if not self.lastRead then
		self.node:send('Request LEDUp')
		return 'error'
	end
	return self:getLastRead()
end

function LED:getLastRead()
	return self.lastRead
end

--- Stringifier for Cloneables.
function LED:toString()
	return string.format("[Remote_LED] %s %s %s",self:getID(),self:getName(),(self.blinking and "blinking" or self:read() == 1 and 'on' or 'off'))
end

return LED
