local Cloneable			= require("obj.Remote_Common")
local mscanner			= require("obj.MacScanner")
local MacScanner			= Cloneable:clone()
--[[
	Object module handling responses from remote mac address scanners
]]

MacScanner.location = 'macScanners'

function MacScanner:setup(options)
	if not _G.macTable then _G.macTable = {} end
	self.foundMacs = {}
	self.lostMacs = {}
	self.config.knownMacs = options.knownMacs
	self.config.macTable = options.macTable
	self.config.wlan	 						= (options and options.wlan or MacScanner.config.wlan)
	self.config.updateTime						= (options and options.updateTime or MacScanner.config.updateTime)
	self.config.timeout							= (options and options.timeout or MacScanner.config.timeout)
	self.config.scanTime						= (options and options.scanTime or MacScanner.config.scanTime)
end

MacScanner.getConfig = mscanner.getConfig
MacScanner.archive = mscanner.archive
MacScanner.getWlan = mscanner.getWlan
MacScanner.getUpTime = mscanner.getUpTime
MacScanner.getTimeout = mscanner.getTimeout
MacScanner.getScantime = mscanner.getScantime
MacScanner.getState = mscanner.getState
MacScanner.getStatus = mscanner.getStatus
MacScanner.getMacTable = mscanner.getMacTable
MacScanner.getFoundStatus = mscanner.getFoundStatus
MacScanner.getLostStatus = mscanner.getLostStatus
MacScanner.getKnownStatus = mscanner.getKnownStatus
MacScanner.getIDInfo = mscanner.getIDInfo
MacScanner.read = mscanner.read


function MacScanner:runLogic(newMacs)
	for addr,timeout in pairs(newMacs) do
		if not self.config.macTable[addr] then
			update = true
		end
		self:addAddr(addr,timeout)
	end
	for i,v in pairs(self.config.macTable) do
		if not newMacs[i] then self:removeAddr(i) update = true end
	end
	local c1 = 0
	for i,v in pairs(self.config.macTable) do
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
	for i,v in pairs(self.config.knownMacs) do print(i, v, self.config.macTable[i]) end
	if update then
		self:updateMasters()
	end
end

function MacScanner:addAddr(addr,timeout)
	if not self.config.macTable[addr] then print(addr,'added to mac list') end
	local date = os.date()
	local stamp = os.time(os.date("*t"))
	if not self.foundMacs[addr] then
		self.foundMacs[addr] = {stamp}
	elseif not self.config.macTable[addr] then
		table.insert(self.foundMacs[addr],stamp)
		self:archive(addr,date,stamp,'Found')
	end
	macTable[addr] = self:getName()
	self.config.macTable[addr] = timeout or 0
end

function MacScanner:removeAddr(addr)
	print(addr,'removed from mac list')
	self.config.macTable[addr] = nil
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

function MacScanner:setConfig(config,foundMacs,lostMacs)
	if not config then return end
	if foundMacs then self.foundMacs = foundMacs end
	if lostMacs then self.lostMacs = lostMacs end
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
			elseif i == 'macTable' then
				self:runLogic(config[i])
			else
				self.config[i] = config[i]
			end
		end
	end
end


function MacScanner:setWlan(id)
	if self.node then self.node:send(([[MacScan %s wlan %s]]):format(self:getID(),id)) end
	--logEvent(self:getName(),self:getName() .. ' setWlan:'..id)
end

function MacScanner:setUpTime(ut)
	if self.node then self.node:send(([[MacScan %s uptime %s]]):format(self:getID(),ut)) end
	--logEvent(self:getName(),self:getName() .. ' setUpTime:'..ut)
end

function MacScanner:setTimeout(t)
	if self.node then self.node:send(([[MacScan %s timeout %s]]):format(self:getID(),t)) end
	--logEvent(self:getName(),self:getName() .. ' setTimeout:'..t)
end

function MacScanner:setScantime(t)
	if self.node then self.node:send(([[MacScan %s scanTime %s]]):format(self:getID(),t)) end
	--logEvent(self:getName(),self:getName() .. ' setScantime:'..t)
end

function MacScanner:setName(name)
	if self.config.name then
		if self.node then
			self.node:send(([[MacScan %s rename %s]]):format(self:getID(),name))
		end
		--logEvent(self:getName(),self:getName() .. ' setName:' .. name)
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
	for i,v in pairs(self.config.macTable) do
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
