local Cloneable			= require("obj.MacAddressScanner")
local MacScanner			= Cloneable:clone()
--[[
	Object module handling responses from remote mac address scanners
]]

--- Constructor for instance-style clones.
function MacScanner:initialize(id,config,macTable,foundMacs,lostMacs,knownMacs,node)
	if not _G.macScanners then _G.macTable = {} _G.macScanners = {name="macScanners"} table.insert(objects,macScanners) objects["macScanners"] = macScanners end
	if not macScanners[id..'_'..node:getID()] then

		table.insert(macScanners,self)

		self.config = {}

		self:setID(id)
		self:setName((config.name or 'macScanner_'..id)..'_'..node:getID())

		self.config.wlan	 						= (config and config.wlan or MacScanner.config.wlan)
		self.config.updateTime						= (config and config.updateTime or MacScanner.config.updateTime)
		self.config.timeout							= (config and config.timeout or MacScanner.config.timeout)
		self.config.scanTime						= (config and config.scanTime or MacScanner.config.scanTime)

		self.macTable = macTable or {}
		self.foundMacs = foundMacs or {}
		self.lostMacs = lostMacs or {}
		self.knownMacs = knownMacs or {}
		for i,v in ipairs(MacScanner.knownMacs) do
			self.knownMacs[v[1]]=v[2]
			self.knownMacs[v[2]]=v[1]
		end
		local conn = env:connect(SQLFile)
		conn:execute([[CREATE TABLE MacScanner (mac TEXT, date TEXT, time TIME, event TEXT)]])
		conn:close()
		node:addMacScanner(self)
	end

end

function MacScanner:removeMacScanner()
	macScanners[self:getName()] = nil
	macScanners[self:getID()] = nil
	while table.removeValue(macScanners, self) do end
	if self.node then local node=self.node self.node=nil node:removeMacScanner(self) end
end

function MacScanner:runLogic(newMacs)

	for addr,timeout in pairs(newMacs) do
		if not self.macTable[addr] then
			update = true
		end
		self:addAddr(addr,timeout)
	end
	for i,v in pairs(self.macTable) do
		if not newMacs[i] then self:removeAddr(i) update = true end
	end
	local c1 = 0
	for i,v in pairs(self.macTable) do
		c1 = c1 + 1
	end
	local c2 = 0
	for i,v in pairs(self.foundMacs) do
		c2 = c2 + 1
	end
	local c3 = 0
	for i,v in pairs(self.lostMacs) do
		c3 = c3 + 1
	end
	print('!!!!!!!!!!!!!!!','Current:'..c1,'Found:'..c2,'Lost:'..c3)
	for i,v in pairs(self.knownMacs) do print(i, v, self.macTable[i]) end
	if update then
		self:updateMasters()
	end

end

function MacScanner:addAddr(addr,timeout)
	if not self.macTable[addr] then print(addr,'added to mac list') end
	local date = os.date()
	local stamp = os.time(os.date("*t"))
	if not self.foundMacs[addr] then
		self.foundMacs[addr] = {stamp}
	elseif not self.macTable[addr] then
		table.insert(self.foundMacs[addr],stamp)
		self:archive(addr,date,stamp,'Found')
	end
	macTable[addr] = self:getName()
	self.macTable[addr] = timeout or 0
end

function MacScanner:removeAddr(addr)
	print(addr,'removed from mac list')
	self.macTable[addr] = nil
	macTable[addr] = nil
	local date = os.date()
	local stamp = os.time(os.date("*t"))
	if not self.lostMacs[addr] then
		self.lostMacs[addr] = {stamp}
	else
		table.insert(self.lostMacs[addr],stamp)
	end
	self:archive(addr,date,stamp,'Lost')
end

function MacScanner:setConfig(config,macTable,foundMacs,lostMacs)
	if not config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'id' then
				macScanners[self.config.id] = nil
				macScanners[config[i]] = self
				self.node.macScanners[self.config.id] = nil
				self.node.macScanners[config[i]] = self
			elseif i == 'name' then
				macScanners[self.config.name] = nil
				macScanners[config[i]] = self
				self.node.macScanners[self.config.name] = nil
				self.node.macScanners[config[i]] = self
			end
			self.config[i] = config[i]
			up = true
		end
	end
	if foundMacs then self.foundMacs = foundMacs end
	if lostMacs then self.lostMacs = lostMacs end
	if macTable then self:runLogic(macTable) end

	if up then
		self:updateMasters()
		logEvent(self:getName(),self:getName() .. ' updated config')
	end
end

function MacScanner:setWlan(id)
	if self.node then self.node:send(([[MacScan %s wlan %s]]):format(self:getID(),id)) end
	logEvent(self:getName(),self:getName() .. ' setWlan:'..id)

end

function MacScanner:setUpTime(ut)
	if self.node then self.node:send(([[MacScan %s uptime %s]]):format(self:getID(),ut)) end
	logEvent(self:getName(),self:getName() .. ' setUpTime:'..ut)

end

function MacScanner:setTimeout(t)
	if self.node then self.node:send(([[MacScan %s timeout %s]]):format(self:getID(),t)) end
	logEvent(self:getName(),self:getName() .. ' setTimeout:'..t)

end

function MacScanner:setScantime(t)
	if self.node then self.node:send(([[MacScan %s scanTime %s]]):format(self:getID(),t)) end
	logEvent(self:getName(),self:getName() .. ' setScantime:'..t)
end

function MacScanner:setID(id)
	if self.config.id then
		if self.node then
			self.node.macScanners[self.config.id] = nil
			self.node.macScanners[id] = self
		end
	else
		self.config.id = id
	end
end

function MacScanner:setName(name)
	if self.config.name then
		if self.node then
			self.node:send(([[MacScan %s rename %s]]):format(self:getID(),name))
		end
		logEvent(self:getName(),self:getName() .. ' setName:' .. name)
	else
		self.config.name = name
	end
end

function MacScanner:setState(state)
	if self.config.state and self.node and state ~= self.config.state then self.node:send(([[MacScan %s setState %s]]):format(self:getID(),state)) end
end


--- Stringifier for Cloneables.
function MacScanner:toString()
	local c1 = 0
	for i,v in pairs(self.macTable) do
		c1 = c1 + 1
	end
	local c2 = 0
	for i,v in pairs(self.foundMacs) do
		c2 = c2 + 1
	end
	local c3 = 0
	for i,v in pairs(self.lostMacs) do
		c3 = c3 + 1
	end
	return string.format("[Remote_MacScanner] %s state:%s Current:%s Found:%s Lost:%s",self:getName(),self:getState(),c1,c2,c3)
end

return MacScanner
