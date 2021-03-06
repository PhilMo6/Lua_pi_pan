local Cloneable			= require("obj.Common")
local MacScanner			= Cloneable:clone()
--[[
	Object module handling wlan scanning and logging of mac addresses and maintaining a list of known addresses
]]

MacScanner.location = 'macScanners'
MacScanner.config = {}
MacScanner.config.wlan 					=  "wlan0"
MacScanner.config.updateTime 			=  120
MacScanner.config.timeout 				=  3
MacScanner.config.scanTime 				=  30

MacScanner.knownMacs = {
		}

--[[Example.knownMacs = {
			{'34:ec:eq:ec:91:12','my_phone'},
			{'fc:c0:b3:73:47:5e','friends_phone'},
			{'01:e0:b0:19:32:14','rpi_greenhouse'}
		}
	]]


function MacScanner:setup(options)
	if not _G.macTable then _G.macTable = {} end
	self.foundMacs = {}
	self.lostMacs = {}
	self.config.knownMacs = {}
	self.config.macTable = {}
	self.config.wlan	 						= (options and options.wlan or MacScanner.config.wlan)
	self.config.updateTime						= (options and options.updateTime or MacScanner.config.updateTime)
	self.config.timeout							= (options and options.timeout or MacScanner.config.timeout)
	self.config.scanTime						= (options and options.scanTime or MacScanner.config.scanTime)
	os.execute(("sudo ifconfig %s down" .. ";" .. "sudo iw dev %s set monitor none" .. ";" .. "sudo ifconfig %s up"):format(self:getWlan(),self:getWlan(),self:getWlan()))
	local conn = env:connect(SQLFile)
	--conn:execute([[DROP TABLE IF EXISTS MacScanner;]])
	conn:execute([[CREATE TABLE MacScanner (mac TEXT, date TEXT, time TIME, event TEXT)]])
	--macscannerLoad(conn)
	conn:close()

	Scheduler:queue(Event:new(function()--event that starts the MacScanners logic
		local MS = self
		self.updateLogic = Event:new(function()--event that runs the MacScanners logic
			MS:runLogic()
			MS.updateLogic.repeatInterval = MS:getUpTime()
		end, MS:getUpTime(), true, 0)
		Scheduler:queue(self.updateLogic)
		MS:runLogic()
		MS.started = true
		for i,v in ipairs(MacScanner.knownMacs) do
			MS.config.knownMacs[v[1]]=v[2]
			MS.config.knownMacs[v[2]]=v[1]
		end
	end, 10, false))
end

function MacScanner:getConfig(firstUp)
	if self.config then
		if firstUp then
			return string.format('%s,foundMacs=%s,lostMacs=%s',table.savetoString(self.config),table.savetoString(self.foundMacs),table.savetoString(self.lostMacs))
		else
			return table.savetoString(self.config)
		end
	else
		return "nil"
	end
end


function MacScanner:archive(mac,d,t,e)
	local conn = env:connect(SQLFile)
	if conn then
		conn:execute(([[INSERT INTO MacScanner values('%s','%s','%s');]]):format(mac,t,d,e))
		conn:close()
	end
end


function MacScanner:runLogic()
	local state = self:getState()
	if state ~= 'off' and not self.scanning then
		local com
		if state == 'active' then
			--this command does a better job of translating mac addresses so will include all devices broadcasting including protocol codes
			com = 'sudo tshark -i '..self:getWlan()..' -a duration:'..self:getScantime() ..[[ -o gui.column.format:'"UnresS","%uhs","ResS","%rhs","UnresD","%uhd","ResD","%rhd"' > scan.out]]
		else
			--basic scan command will capture most devices but will ignore some such as routers and protocols due to their mac addresses not being translated
			com = 'sudo tshark -i '..self:getWlan()..' -a duration:'..self:getScantime() ..' > scan.out'
		end
		os.execute(com .. "&")
		Scheduler:queue(Event:new(function()
			local macScan = io.open('scan.out','r')
			if macScan then
				local update
				local r = macScan:read('*all')
				macScan:close()
				macScan = nil
				local currentScan = {}
				for addr in string.gmatch(r, "(%w%w:%w%w:%w%w:%w%w:%w%w:%w%w)") do
					if not currentScan[addr] and addr ~= 'ff:ff:ff:ff:ff:ff' and not string.find(addr,'33:33:00:00:00:') then
						currentScan[addr] = true
						self:addAddr(addr)
						update = true
					end
				end
				for i,v in pairs(self.config.macTable) do
					if not currentScan[i] then self.config.macTable[i] = self.config.macTable[i] + 1 end
					if self.config.macTable[i] >= self:getTimeout() then self:removeAddr(i) update = true end
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
				self.scanning = nil
			end
		end, self:getScantime()+10, false))
		self.scanning = true
	end
end

function MacScanner:addAddr(addr)
	if not self.config.macTable[addr] then print(addr,'added to mac list') end
	local date = os.date()
	local stamp = os.time(os.date("*t"))
	self:archive(addr,date,stamp,'Found')
	if not self.foundMacs[addr] then
		self.foundMacs[addr] = {stamp}
	elseif not self.config.macTable[addr] then
		table.insert(self.foundMacs[addr],stamp)
	end
	macTable[addr] = self:getName()
	self.config.macTable[addr] = 0
end

function MacScanner:removeAddr(addr)
	print(addr,'removed from mac list')
	self.config.macTable[addr] = nil
	macTable[addr] = nil
	local date = os.date()
	local stamp = os.time(os.date("*t"))
	self:archive(addr,date,stamp,'Lost')
	if not self.lostMacs[addr] then
		self.lostMacs[addr] = {stamp}
	else
		table.insert(self.lostMacs[addr],stamp)
	end
end

function MacScanner:isAddr(addr)
	return self.config.macTable[addr]
end
function MacScanner:isID(id)
	if self.config.knownMacs[id] and not self.config.macTable[id] then id = self.config.knownMacs[id] end
	if self.config.macTable[id] then
		return true
	end
	return false
end

function MacScanner:setConfig(config)
	if not config then return end
	local up = nil
	for i,v in pairs(self.config) do
		if config[i] and config[i] ~= v then
			if i == 'name' then
				self:setName(config[i])
			elseif i == 'id' then
				self:setID(config[i])
			else
				self.config[i] = config[i]
			end
			up = true
		end
	end
	if up then	self:updateMasters() end
end

function MacScanner:setWlan(id)
	self.config.wlan = id
	logEvent(self:getName(),self:getName() .. ' setWlan:'..id)
	self:updateMasters()
end

function MacScanner:getWlan()
	return self.config.wlan
end

function MacScanner:setUpTime(ut)
	self.config.updateTime = ut
	logEvent(self:getName(),self:getName() .. ' setUpTime:'..ut)
	self:updateMasters()
end

function MacScanner:getUpTime()
	return self.config.updateTime
end

function MacScanner:setTimeout(t)
	self.config.timeout = t
	logEvent(self:getName(),self:getName() .. ' setTimeout:'..t)
	self:updateMasters()
end

function MacScanner:getTimeout()
	return self.config.timeout
end

function MacScanner:setScantime(t)
	self.config.scanTime = t
	logEvent(self:getName(),self:getName() .. ' setScantime:'..t)
	self:updateMasters()
end

function MacScanner:getScantime()
	return self.config.scanTime
end

function MacScanner:setState(state)
	local states = {
	['passive']=function() end,
	['active']=function() end,
	['off']=function() end,
	}
	if not state then state = 'passive' end
	if self.config.state ~= state and states[state] then
		self.config.state = state
		if self.started then
			if type(states[state]) == "function" then
				states[state]()
			end
			logEvent(self:getName(),self:getName() .. ' state:' .. state)
			self:runLogic()
			self:updateMasters()
		end
	end
end

function MacScanner:getHTMLcontrol()
	local id = self:getID()
	return ('<div style="font-size:15px">%s %s %s %s %s %s %s<br>%s</div>'):format(
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s stat')">Status</button >]]):format(id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s MacTable','%s')">Current Mac List</button >]]):format(id,id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s statKnown','%s')">Know Status</button >]]):format(id,id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s statFound','%s')">Found Status</button >]]):format(id,id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s statLost','%s')">Lost Status</button >]]):format(id,id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s IDinfo','%s')">ID Info</button >]]):format(id,id),
	([[<button style="font-size:15px" onclick="myFunction('MacScan %s toggle')">Toggle</button >]]):format(id),
	([[<form id="%s"> find:<input type="text" name='com'></form>]]):format(id)
	)
end

function MacScanner:getState()
	return self.config.state or 'off'
end

function MacScanner:read()
	return self:getState()
end

function MacScanner:toggle()
	logEvent(self:getName(),self:getName() .. ' toggle')
	if  self:getState() == 'off' then
		self:setState('passive')
		return 'passive'
	elseif self:getState() == 'passive' then
		self:setState('active')
		return 'active'
	elseif self:getState() == 'active' then
		self:setState('off')
		return 'off'
	else
		self:setState('off')
		return 'off'
	end
end

function MacScanner:getStatus()
	local status = table.writetoString(self.config)
	return string.format("%s\n%s",self:toString(),status)
end

function MacScanner:getMacTable()
	return table.writetoString(self.config.macTable)
end

function MacScanner:getFoundStatus(id)
	local tab = self.foundMacs
	if id and tab[id] then tab = tab[id] end
	local status = table.writetoString(tab)
	return string.format("%s\n%s",self:toString(),status)
end
function MacScanner:getLostStatus(id)
	local tab = self.lostMacs
	if id and tab[id] then tab = tab[id] end
	local status = table.writetoString(tab)
	return string.format("%s\n%s",self:toString(),status)
end
function MacScanner:getKnownStatus(id)
	if id then
		if self.config.knownMacs[id] then return string.format("\n%s %s %s",id,self.config.knownMacs[id],self.config.macTable[i] and 'Found' or 'Lost') end
	end
	local re = ""
	for i,v in pairs(self.config.knownMacs) do re = string.format("%s\n%s %s %s",re,i,v,self.config.macTable[i] and 'Found' or 'Lost') end
	return re
end
function MacScanner:getIDInfo(id)
	if not id then
		return 'Must supply ID!'
	else
		if self.config.knownMacs[id] and not self.config.macTable[id] then id = self.config.knownMacs[id] end
	end
	local re = ""
	if self.config.knownMacs[id] then
		local ForL = self.config.macTable[id] and 'Found' or 'Lost'
		re = string.format("%s\n%s %s %s",re,id,self.config.knownMacs[id],ForL)
	end
	if  self.foundMacs[id] then
		re = string.format("%s\nLast found %s ago",re,SecondsToClock(os.time(os.date("*t")) - self.foundMacs[id][#self.foundMacs[id]]))
		re = string.format("%s\n Found Data = %s",re,table.writetoString(self.foundMacs[id]))
	end
	if self.lostMacs[id] then
		re = string.format("%s\nLast lost %s ago",re,SecondsToClock(os.time(os.date("*t")) - self.lostMacs[id][#self.lostMacs[id]]))
		re = string.format("%s\n Lost Data = %s",re,table.writetoString(self.lostMacs[id]))
	end
	return (re ~= "" and re or "No info for the ID "..id.." was found...")
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
	return string.format("[MacScanner] %s state:%s Current:%s Found:%s Lost:%s",self:getName(),self:getState(),c1,c2,c3)
end

return MacScanner
