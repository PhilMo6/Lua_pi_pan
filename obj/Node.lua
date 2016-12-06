local Cloneable						= require("obj.Cloneable")
local Node							= Cloneable.clone()
--[[
	Node client object.
	Applied by a master to a client object when a client ip address matches a configured node in the main config file.
]]

function Node:initialize(client)
	self.config = {}
	self.objects = {}
	self.objectIDs = {}
	self.client = client
	local addr, port = client:getAddress()
	self.ip = addr
	self.port = port
	client.node = self
	local msg = 'Request objects'
	if nodeList[self.ip].objects then
		msg = msg .. " ("
		for i,v in ipairs(nodeList[self.ip].objects) do
			msg = msg .. " " .. v
		end
		msg = msg .. " )"
	end
	Scheduler:queue(Event:new(function()
		self:send(msg)
	end, 10, false))
	table.insert(nodes,self)
	nodes[addr] = self
	--setNode(addr)
end

function Node:getHTMLcontrol()
	local ip,port = self:getAddress()
	return ([[%s %s]]):format(
	([[<button onclick="myFunction('Node %s stop')">Shutdown</button >]]):format(ip),
	([[<button onclick="myFunction('Node %s stop restart')">Restart</button >]]):format(ip)
	)
end

function Node:addObject(obj)
	if self.objects[obj.location] == nil then
		self.objects[obj.location] = {}
	end
	if self.objectIDs[obj:getID()] == nil then
		self.objectIDs[obj:getID()] = obj
		self.objects[obj.location][obj:getName()] = obj
		table.insert(self.objects[obj.location], obj)
		obj.node = self
	end
end
function Node:removeObject(obj)
	if self.objectIDs[obj:getID()] then
		self.objectIDs[obj:getID()] = nil
		self.objects[obj.location][obj:getName()] = nil
		while table.removeValue(self.objects[obj.location], obj) do end
		if obj.masters then obj:removeMaster(self) end
		if obj.node and obj.node == self then obj.node = nil obj:removeSelf() end
		if #self.objects[obj.location] == 0 then
			self.objects[obj.location] = nil
		end
	end
end

function Node:toString()
	if not self.client then
		return "Node@nil"
	end
	local addr, port = self.client:getAddress()
	return string.format("Node@%s", addr)
end

function Node:receive(pattern, prefix)
	return self.client:receive(pattern, prefix)
end

function Node:send(data, i, j)
	return self.client:send(data, i, j)
end

function Node:getAddress()
	return self.ip,self.port
end

function Node:getID()
	return nodeList[self.ip].id
end

function Node:destoy()
	for i,v in pairs(self.objects) do
		for i,v in ipairs(v) do
			self:removeObject(v)
		end
	end
	self = nil
end

function Node:removeSelf()
	if runningServer and self.client and self.client.socket then
		runningServer:disconnectClient(self.client)
	end
	self:destoy()
end

return Node
