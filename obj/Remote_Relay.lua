local Cloneable			= require("obj.Relay")
local Relay			= Cloneable:clone()
--[[
	Remote object for relay attached to nodes.
	Node will update the relay as changes are detected.
]]

function Relay:initialize(id,name,node)
	if not _G.relays then _G.relays = {name='relays'} table.insert(objects,relays) objects["relays"] = relays end
	if not relays[name..'_'..node:getID()] then
		self.config = {}
		self:setID(id)
		self:setName(name..'_'..node:getID())
		node:addRelay(self)
		table.insert(relays,self)
	end
end

function Relay:removeRelay()
	relays[self:getName()] = nil
	while table.removeValue(relays, self) do end
	if self.node then local node=self.node self.node=nil node:removeRelay(self) end
end

function Relay:getHTMLcontrol()
	return ([[%s %s <form id="%s"> for <input type="text" name='com'></form>]]):format(
	([[<button onclick="myFunction('r %s on','%s')">On</button >]]):format(self:getName(),self:getName()),
	([[<button onclick="myFunction('r %s off','%s')">Off</button >]]):format(self:getName(),self:getName())
	,self:getName()
	)
end

function Relay:setID(id)
	if self.config.id then
		if self.node then
			self.node.relays[self.config.id] = nil
			self.node.relays[id] = self
		end
	end
	self.config.id = id
end

function Relay:setName(name)
	if self.config.name then
		relays[self.config.name] = nil
		if self.node then
			self.node:send(([[R %s rename %s]]):format(self:getID(),name))
			self.node.relays[self.config.name] = nil
			self.node.relays[name] = self
		end
	end
	self.config.name = name
	relays[self.config.name] = self
end

function Relay:updateLastRead(v)
	local lastread = self.lastRead
	self.lastRead = v
	if self.masters and lastread ~= self.lastRead then
		self:updateMasters()
	end
end

function Relay:toggle(client)
	if self:readO() == true then
		self:on(client)
		return 'on'
	else
		self:off(client)
		return 'off'
	end
end

function Relay:off(client)
	if self:readO() == false and not self.stayOn then
		self.node:send(([[R %s off]]):format(self:getID()))
		return true
	end
	return false
end

function Relay:on(client)
	if self:readO() == true and not self.stayOff then
		self.node:send(([[R %s on]]):format(self:getID()))
		return true
	end
	return false
end

function Relay:readO()
	if self.lastRead == nil then
		self.node:send('Request RlUp')
		return 'error'
	end
	return self:getLastRead()
end

function Relay:getLastRead()
	return self.lastRead
end

function Relay:toString()
	return string.format("[Remote_relay] %s %s %s",self:getID(),self:getName(),(self:readO() == true and 'off' or 'on'))
end

return Relay
