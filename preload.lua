

--[[
	preload loads all the global functions that are used throughout the program.
]]


_G.masters						= {}
_G.nodes						= {}
local MacScanner = require("obj.MacAddressScanner")
local Thermostat = require("obj.Thermostat")
local MotionSensor = require("obj.MotionSensor")
local TempSensor = require("obj.1w_TempSensor")
local DHT22 = require("obj.DHT22")
local LightSensor = require("obj.LightSensor")
local Relay = require("obj.Relay")
local LED = require("obj.LED")
local RBG_LED = require("obj.RBG_LED")
local Buzzer = require("obj.Buzzer")
local Button = require("obj.Button")

--found here https://gist.github.com/jesseadams/791673
function _G.SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

function _G.sleep(t)
	local d = socket.gettime() + t
	while socket.gettime() < d do end
	return
end

function _G.logEvent(objID,event,conn,c)
	if run then
		if not conn then conn = env:connect(SQLFile) else c = true end
		local stamp = socket.gettime()
		conn:execute([[CREATE TABLE EVENTS (id TEXT, stamp TEXT, event TEXT);]])
		conn:execute("INSERT INTO EVENTS values('"..objID.."','"..stamp.."','"..event.."');")
		if not c then conn:close() else return conn end
	end
end

function _G.boxLoad(data)
	local sandbox_env = {
	}
	local chunk,er = loadstring(data)
	local re = nil
	if chunk then
		setfenv(chunk, sandbox_env)
		re = chunk()
	end
	return re
end

function _G.loadData(data)
	data = "return " ..data
	local re = boxLoad(data)
	return re
end

function _G.loadObjects(conn,c)
	if not conn then conn = env:connect(SQLFile) else c = true end
	if not _G.objects then _G.objects = {} end

	--setup all devices/pins
	for i,pin in ipairs(buttonPins) do
		if type(pin) == 'number' then
			Button:new(pin)
		end
	end
	for i,pin in ipairs(buzzerPins) do
		if type(pin) == 'number' then
			Buzzer:new(pin)
		end
	end
	for i,pin in ipairs(LEDPins) do
		if type(pin) == 'number' then
			LED:new(pin)
		end
	end
	for i,op in ipairs(RBG_LEDPins) do
		if type(op[1]) == 'number' then
			RBG_LED:new(op[1],op[2],op[3])
		end
	end
	for i,pin in ipairs(relayPins) do
		if type(pin) == 'number' then
			Relay:new(pin)
		end
	end
	for i,pin in ipairs(lightSensorPins) do
		if type(pin) == 'number' then
			LightSensor:new(pin)
		end
	end
	for i,pin in ipairs(DHT22Pins) do
		if type(pin) == 'number' then
			DHT22:new(pin)
		end
	end

	--check for 1 wire sensors to add to the sensors table
	--only temp sensors for now
	for i,v in ipairs(scandir("/sys/bus/w1/devices",true)) do
		if v ~= "." and v ~= ".." and v ~= "w1_bus_master1" then
			TempSensor:new(v)
		end
	end

	--start up higher logic objects after all required objects are loaded
	for i,op in ipairs(thermostatStartup) do
		Thermostat:new(op[1],op[2])
	end
	for i,op in ipairs(motionSensorStartup) do
		MotionSensor:new(op[1],op[2],op[3])
	end
	for i,op in ipairs(macScannerStartup) do
		MacScanner:new(op[1],op[2])
	end

	--for easier object lookup
	for i,v in ipairs(objects) do
		objects[v.name] = v
	end
	if not c then conn:close() else return conn end
end

function _G.objectUpdate(conn,c)
	if not conn then conn = env:connect(SQLFile) else c = true end
	updateButtonNames(conn)
	updateBuzzerNames(conn)
	updateLEDNames(conn)
	updateRelayNames(conn)
	updateLSensorNames(conn)
	updateSensorNames(conn)
	updateThermostatInfo(conn)
	updateMotionSensorsInfo(conn)
	updateSiteLinks(conn)
	updateSensorLinks(conn)
	updateMacScannerInfo(conn)
	if not c then conn:close() else return conn end
end

function _G.objectLoad(conn,c)
	if not conn then conn = env:connect(SQLFile) else c = true end

	--retrieve saved names for objects
	local cursor,errorString = conn:execute([[select * from Buttons]])
	if cursor then
		local row = cursor:fetch ({}, "a")
		while row do
			if buttonIDs and buttonIDs[tonumber(row.id)] then
				buttonIDs[tonumber(row.id)]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from LightSensors]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if lightsensorIDs and lightsensorIDs[tonumber(row.id)] then
				lightsensorIDs[tonumber(row.id)]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from Buzzers]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if buzzerIDs and buzzerIDs[tonumber(row.id)] then
				buzzerIDs[tonumber(row.id)]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from LEDs]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if LEDIDs and LEDIDs[tonumber(row.id)] then
				LEDIDs[tonumber(row.id)]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from Relays]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if relayIDs and relayIDs[tonumber(row.id)] then
				relayIDs[tonumber(row.id)]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from TempSensors]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if sensors and sensors[row.id] then
				sensors[row.id]:setName(row.name)
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from Thermostats]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if thermostats and thermostats[row.id] then
				local bl = boxLoad(row.config)
				if bl then thermostats[row.id]:setConfig(bl) end
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	cursor,errorString = conn:execute([[select * from MotionSensors]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if motionSensors and motionSensors[row.id] then
				local bl = boxLoad(row.config)
				if bl then motionSensors[row.id]:setConfig(bl) end
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end
	macscannerLoad(conn)

	if not c then conn:close() else return conn end
end




function _G.HTMLcontrols()
	local html = [[--Controls--<br><select id="selectControls" onchange="divChange(this)">]]
	if runningServer then
		html = ([[%s <option value="server">Server</option>]]):format(html)
	end
	for i,t in ipairs(objects) do
		if #t > 0 then
			html = ([[%s <option value="%s">%s</option>]]):format(html,t.name,string.firstToUpper(t.name))
		end
	end
	html = ("%s </select>"):format(html)
    return html
end

function _G.HTMLcontrols2(id)
	if id == 'server' then
		return ("--Server-- <p> %s </p>"):format(runningServer:getHTMLcontrol())
	else
		local objTable = objects[id]
		local html = nil
		if objTable and #objTable > 0 then
			html = ("--%s-- <p>"):format(string.firstToUpper(objTable.name))
			for i,v in ipairs(objTable) do
				html = ("%s <p> %s %s </p>"):format(html,v:getName(),v:getHTMLcontrol())
			end
			html = ("%s </p>"):format(html)
		elseif objTable and #objTable == 0 then
			html = "No controls for this selection..."
		end
		return html
	end
end

function _G.getStatus()
	local msg = "-Status-"
	for i,t in ipairs(objects) do
		for i,v in ipairs(t) do
			msg = ('%s\n%s'):format(msg,v:toString())
		end
	end
    return msg
end

function _G.updateSiteLinks(conn,c)
	if not conn then conn = env:connect(SQLFile) else c = true end
	conn:execute([[DROP TABLE IF EXISTS MASTERLinks;]])
	conn:execute([[CREATE TABLE MASTERLinks (link TEXT);]])
	for i,link in ipairs(siteLinks) do
		conn:execute("INSERT INTO MASTERLinks values('"..link.."');")
	end
	if not c then conn:close() else return conn end
end

function _G.updateSensorLinks(conn,c)
	if not conn then conn = env:connect(SQLFile) else c = true end
	local function addtodatabase(index,val)
		local cursor,errorString2 = conn:execute(([[SELECT * FROM MasterSensors WHERE name='%s';]]):format(index))
		local row = cursor:fetch ({}, "a")
		if row then
			local status,errorString = conn:execute(([[UPDATE MasterSensors SET (name="%s",loc="%s") WHERE name="%s";]]):format(index,val,index))
		else
			conn:execute("INSERT INTO MasterSensors values('"..index.."','"..val.."');")
		end
		cursor:close()
	end

	conn:execute([[CREATE TABLE MasterSensors (name TEXT, loc TEXT);]])
	if sensors then
		for i,sensor in ipairs(sensors) do
			addtodatabase(sensor:getName(),'temp')
		end
	end
	if DHT22s then
		for i,sensor in ipairs(DHT22s) do
			addtodatabase(sensor:getName()..'_h','humidity')
			addtodatabase(sensor:getName()..'_t','temp')
		end
	end
	if lightsensors then
		for i,sensor in ipairs(lightsensors) do
			addtodatabase(sensor:getName(),'light')
		end
	end
	if not c then conn:close() else return conn end
end


function _G.removeSensorLink(senId)
	local conn = env:connect(SQLFile)
	local re = nil
	if senId then
		local cursor,errorString = conn:execute(([[SELECT * FROM MasterSensors WHERE name='%s';]]):format(senId))
		local row = cursor:fetch ({}, "a")
		if row then
			local cursor,errorString = conn:execute(([[DELETE FROM MasterSensors WHERE name='%s';]]):format(senId))
			re = ('Removed %s from MasterSensors database...'):format(senId)
		else
			re = 'Provided ID doesnt match any in MasterSensors database...'
		end
		cursor:close()
	else
		re = 'Must provided valid sensor id ID...'
	end
	conn:close()
	return re
end



function _G.setMaster(masterIP,conn,c)
	if masters == nil then _G.masters = {} end
	if not conn then conn = env:connect(SQLFile) else c = true end
	local status,errorString1 = conn:execute([[CREATE TABLE Masters (ip TEXT);]])
	local cursor,errorString2 = conn:execute(("select * from Masters where ip='%s';"):format(masterIP))
	local row = cursor:fetch ({}, "a")
	if row then
		local status,errorString = conn:execute(([[UPDATE Masters SET ip="%s" WHERE ip="%s";]]):format(masterIP,masterIP))
	else
		local com = "INSERT INTO Masters values('"..masterIP.."');"
		local status,errorString = conn:execute(com)
	end
	cursor:close()
	if not c then conn:close() else return conn end
end

function _G.setNode(nodeIP,conn,c)
	if nodes == nil then _G.nodes = {} end
	if not conn then conn = env:connect(SQLFile) else c = true end
	local status,errorString1 = conn:execute([[CREATE TABLE Nodes (ip TEXT);]])
	local cursor,errorString2 = conn:execute(("select * from Nodes where ip='%s';"):format(nodeIP))
	local row = cursor:fetch ({}, "a")
	if row then
		local status,errorString = conn:execute(([[UPDATE Nodes SET ip="%s" WHERE ip="%s";]]):format(nodeIP,nodeIP))
	else
		local com = "INSERT INTO Nodes values('"..nodeIP.."');"
		local status,errorString = conn:execute(com)
	end
	cursor:close()
	if not c then conn:close() else return conn end
end


--functions for updating names of objects
--runs each function at startup to save any new objects into database
function _G.updateButtonNames(conn,c)
	if not buttons then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS Buttons;]])
	conn:execute([[CREATE TABLE Buttons (id TEXT, name TEXT, config TEXT)]])
	for i,v in ipairs(buttons) do
		local cursor,errorString = conn:execute(("select * from Buttons where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE Buttons SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO Buttons values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO Buttons values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateBuzzerNames(conn,c)
	if not buzzers then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS Buzzers;]])
	conn:execute([[CREATE TABLE Buzzers (id TEXT, name TEXT, config TEXT)]])
	for i,v in ipairs(buzzers) do
		local cursor,errorString = conn:execute(("select * from Buzzers where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE Buzzers SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO Buzzers values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO Buzzers values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateLEDNames(conn,c)
	if not LEDs then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS LEDs;]])
	conn:execute([[CREATE TABLE LEDs (id TEXT, name TEXT, config TEXT)]])
	for i,v in ipairs(LEDs) do
		local cursor,errorString = conn:execute(("select * from LEDs where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE LEDs SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO LEDs values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateRelayNames(conn,c)
	if not relays then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS Relays;]])
	conn:execute([[CREATE TABLE Relays (id TEXT, name TEXT, config TEXT);]])
	for i,v in ipairs(relays) do
		local cursor,errorString = conn:execute(("select * from Relays where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE Relays SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO Relays values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO Relays values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateSensorNames(conn,c)
	if not sensors then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS TempSensors;]])
	conn:execute([[CREATE TABLE TempSensors (id TEXT, name TEXT, config TEXT);]])
	for i,v in ipairs(sensors) do
		local cursor,errorString = conn:execute(("select * from TempSensors where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE TempSensors SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO TempSensors values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO TempSensors values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateLSensorNames(conn,c)
	if not lightsensors then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS LightSensors;]])
	conn:execute([[CREATE TABLE LightSensors (id TEXT, name TEXT, config TEXT);]])
	for i,v in ipairs(lightsensors) do
		local cursor,errorString = conn:execute(("select * from LightSensors where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE LightSensors SET name='%s',config='%s' WHERE id='%s';]]):format(v:getName(),v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO LightSensors values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO LightSensors values('%s','%s','%s');]]):format(v:getID(),v:getName(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateThermostatInfo(conn,c)
	if not thermostats then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS Thermostats;]])
	conn:execute([[CREATE TABLE Thermostats (id TEXT, config TEXT);]])
	for i,v in ipairs(thermostats) do
		local cursor,errorString = conn:execute(("select * from Thermostats where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE Thermostats SET config='%s' WHERE id='%s';]]):format(v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO Thermostats values('%s','%s');]]):format(v:getID(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO Thermostats values('%s','%s');]]):format(v:getID(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.updateMotionSensorsInfo(conn,c)
	if not motionSensors then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--conn:execute([[DROP TABLE IF EXISTS MotionSensors;]])
	conn:execute([[CREATE TABLE MotionSensors (id TEXT, config TEXT);]])
	for i,v in ipairs(motionSensors) do
		local cursor,errorString = conn:execute(("select * from MotionSensors where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE MotionSensors SET config='%s' WHERE id='%s';]]):format(v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO MotionSensors values('%s','%s');]]):format(v:getID(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO MotionSensors values('%s','%s');]]):format(v:getID(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end

function _G.updateMacScannerInfo(conn,c)
	if not macScanners then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	conn:execute([[CREATE TABLE macScanners (id TEXT, config TEXT);]])
	for i,v in ipairs(macScanners) do
		local cursor,errorString = conn:execute(("select * from macScanners where id='%s';"):format(v:getID()))
		if cursor then
			local row = cursor:fetch ({}, "a")
			if row then
				conn:execute(([[UPDATE macScanners SET config='%s' WHERE id='%s';]]):format(v:getConfig(),v:getID()))
			else
				conn:execute(([[INSERT INTO macScanners values('%s','%s');]]):format(v:getID(),v:getConfig()))
			end
			cursor:close()
		else
			conn:execute(([[INSERT INTO macScanners values('%s','%s');]]):format(v:getID(),v:getConfig()))
		end
	end
	if not c then conn:close() else return conn end
end
function _G.macscannerLoad(conn,c)
	if not macScanners then return end
	if not conn then conn = env:connect(SQLFile) else c = true end
	--retrieve saved info for macscanner
	local cursor,errorString = conn:execute([[select * from macScanners;]])
	if cursor then
		row = cursor:fetch ({}, "a")
		while row do
			if macScanners[row.id] then
				local bl = boxLoad(row.config)
				if bl then macScanners[row.id]:setConfig(bl) end
			end
			row = cursor:fetch (row, "a")
		end
		cursor:close()
	end

	if not c then conn:close() else return conn end
end


function _G.startPollSensorEvent()
	if not _G.pollSensorEvent then
		_G.pollSensorEvent = Event:new(function()--sensor update event
			pollSensors()
		end, sensorUpdateTime, true, 0)
		Scheduler:queue(_G.pollSensorEvent)
    end
	if not _G.logSensorEvent then
		_G.logSensorEvent = Event:new(function()--log sensors event
			pollSensors(false,true)
		end, sensorLogTime, true, 0)
		Scheduler:queue(_G.logSensorEvent)
	end
end

--polls all the sensors to update their last read
--if p then print the readings or er
function _G.pollSensors(p,log)
	local conn = env:connect(SQLFile)
	if conn then
		local stamp = os.time(os.date("*t"))
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		if sensors then
			conn:execute([[CREATE TABLE temp (id TEXT, name TEXT, stamp time, tdate date, ttime time, cel INTEGER, fah INTEGER)]])
			for i,v in ipairs(sensors) do
				local t1,t2,er = v:read()
					if not er then
					if log then
						local status,errorString = conn:execute("INSERT INTO temp values('" .. v:getID() .. "','" .. v:getName() .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "','" .. t2 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2) end
				else
					if p then print(v:getID(),v:getName(),er) end
				end
			end
		end
		if DHT22s then
			conn:execute([[CREATE TABLE temp (id TEXT, name TEXT, stamp time, tdate date, ttime time, cel INTEGER, fah INTEGER)]])
			conn:execute([[CREATE TABLE humidity (id TEXT, name TEXT, stamp time, tdate date, ttime time, hum INTEGER)]])
			for i,v in ipairs(DHT22s) do
				local t1,t2 = v:read()
				local t3 = (t2 * 9 / 5  + 32)
				if t1 then
					if log then
						local status,errorString = conn:execute("INSERT INTO temp values('" .. v:getID() .. "','" .. v:getName()..'_t' .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t2 .. "','" .. t3 .. "')")
						local status,errorString = conn:execute("INSERT INTO humidity values('" .. v:getID() .. "','" .. v:getName()..'_h' .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2,t3) end
				else
					if p then print(v:getID(),v:getName(),'error') end
				end
			end
		end
		if lightsensors then
			conn:execute([[CREATE TABLE light (id TEXT, name TEXT, stamp time, tdate date, ttime time, lightlevel INTEGER)]])
			for i,v in ipairs(lightsensors) do
				local t1,t2,er = v:read()
				if not er then
					if log then
						local status,errorString = conn:execute("INSERT INTO light values('" .. v:getID() .. "','" .. v:getName() .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2) end
				else
					if p then print(v:getID(),v:getName(),er) end
				end
			end
		end
		conn:close()
	else
		print('sql connect error on poll')
	end
end

--t is base time to be converted
function _G.timeM(t,multiplier)
	if multiplier == "m" or multiplier == "min" or multiplier == "minute" then
		t = t * 60
	elseif multiplier == "h" or multiplier == "hour" then
		t = t * (60 * 60)
	elseif multiplier == "d" or multiplier == "day" then
		if t > 7 then t = t end--lua can only work with numbers so large before taking it into account.
		t = t * (60 * 60 * 24)
	end
	return t
end

function _G.scandir(directory,home)
	if not home then directory = homeDirectory .. directory end
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls -a "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

