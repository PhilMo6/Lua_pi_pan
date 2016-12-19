local Cloneable						= require("obj.Node")
local Master						= Cloneable:clone()
--[[
	Master client object.
	Applied by a node to a client object when a clients ip address matches a configured master in the main config file.
]]

function Master:initialize(client)
	self.config = {}
	self.objects = {}
	self.objectIDs = {}
	self.client = client
	local addr, port = client:getAddress()
	self.ip = addr
	self.port = port
	client.master = self
	table.insert(masters,self)
	masters[addr] = self
	runningServer:ping(self)
end

function Master:addObject(obj)
	if self.objects[obj.location] == nil then
		self.objects[obj.location] = {}
	end
	if self.objectIDs[obj:getID()] == nil then
		self.objectIDs[obj:getID()] = obj
		self.objects[obj.location][obj:getName()] = obj
		table.insert(self.objects[obj.location], obj)
		obj:addMaster(self)
	end
end

function Master:getID()
	return masterList[self.ip].id
end

function Master:destoy()
	for i,v in pairs(self.objects) do
		for i,v in pairs(v) do
			self:removeObject(v)
		end
	end
	local addr, port = self:getAddress()
	masters[addr] = nil
	while table.removeValue(masters, self) do end
	self = nil
end

function Master:toString()
	if not self.client then
		return "Master@nil"
	end
	local addr, port = self.client:getAddress()
	return string.format("Master@%s", addr)
end

return Master
