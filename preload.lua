

--[[
	preload loads all the global functions that are used throughout the program and does some basic setup.
]]

math.randomseed(os.time())
math.random()
for i=1,math.random(5,10) do
	math.random()
end

_G.masters						= {}
_G.nodes						= {}

local Motor = require("obj.Motor_L298N")
local ServorMotor = require("obj.ServoMotor")
local StepperMotor = require("obj.StepperMotor")
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


function _G.getNewID(length)
	math.random()
	length = length or 10
	if length < 1 then length = 10 end
	local function randomID()
		local array = {}
		local ns = 0
		for i = 1, length do
			if ns == 0 then
				ns = 1
				local n = math.random(0,9)
				array[i] = n
			else
				ns = 0
				local s = string.char(math.random(48, 122))
				if not string.find(s,'%p') then array[i] = s else array[i] = '0' end
			end
		end
		return table.concat(array)
	end
	local id = randomID()
	while objectIDs[id] do id = randomID() end

	local c
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	SQLconn:execute("INSERT INTO ObjectIdList values('"..id.."');")
	if c then SQLconn:close() _G.SQLconn = nil end

	return id
end


--[[
The speed that the program runs events at is gotten with the getFrequency() function.
Objects can request a boost in frequency but must also reset the boost after whatever task is compleated.
Each step increse in frequency doubles the percent of needed processor to manage events.
Only set frequency with boostFrequency() function.
]]

local freqs = {[1]=0.1,[2]=0.01,[3]=0.001,[4]=0.0001}
local frequency = 1
local frequencyBoost = {}
function _G.resetBoost(obj)
	if frequencyBoost and frequencyBoost[obj] then
		frequencyBoost[obj] = nil
		table.removeValue(frequencyBoost,obj)
		setFrequency(1)
		if #frequencyBoost > 0 then
			for i,v in ipairs(frequencyBoost) do
				if frequency < v then setFrequency(v) end
			end
		end
	end
end
function _G.boostFrequency(obj,v)
	if not freqs[v] then return false end
	if not frequencyBoost[obj] then
		frequencyBoost[obj] = v
		table.insert(frequencyBoost,obj)
		if frequency < v then setFrequency(v) end
		return true
	end
	return false
end
function setFrequency(v)
	if v and freqs[v] then
		frequency = v
	else
		frequency = 1
	end
end
function _G.getFrequency()
	return (frequency and freqs[frequency] or freqs[1])
end

function _G.sleep(t)
	local d = socket.gettime() + t
	while socket.gettime() < d do end
	return
end

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

function _G.logEvent(objID,event,c)
	if run then
		if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
		local stamp = socket.gettime()
		SQLconn:execute([[CREATE TABLE EVENTS (id TEXT, stamp TEXT, event TEXT);]])
		SQLconn:execute("INSERT INTO EVENTS values('"..objID.."','"..stamp.."','"..event.."');")
		if c then SQLconn:close() _G.SQLconn = nil end
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

function _G.loadObjects(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	if not _G.objects then _G.objects = {} end
	if not _G.objectIDs then--load object ids first so that no ids are assigned twice
		_G.objectIDs = {}
		SQLconn:execute(([[CREATE TABLE %s (id TEXT,obj TEXT)]]):format('ObjectIdList'))
		local cursor,errorString = SQLconn:execute(("select * from %s;"):format('ObjectIdList'))
		if cursor then
			local row = cursor:fetch ({}, "a")
			while row do
				objectIDs[row.id] = true
				row = cursor:fetch (row, "a")
			end
			cursor:close()
		end
	end

	--setup all devices/pins
	for i,pin in ipairs(buttonPins) do
		if type(pin) == 'number' then
			Button:new(pin,{pin=pin})
		elseif type(pin) == 'table' then--options are pin and edge
			Button:new(pin.pin,pin)
		end
	end
	for i,pin in ipairs(buzzerPins) do
		if type(pin) == 'number' then
			Buzzer:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			Buzzer:new(pin.pin,pin)
		end
	end
	for i,pin in ipairs(LEDPins) do
		if type(pin) == 'number' then
			LED:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			LED:new(pin.pin,pin)
		end
	end
	for i,op in ipairs(RBG_LEDPins) do
		if type(op) == 'table' then
			RBG_LED:new(op.pinR..','..op.pinB..','..op.pinG,op)
		end
	end
	for i,pin in ipairs(relayPins) do
		if type(pin) == 'number' then
			Relay:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			Relay:new(pin.pin,pin)
		end
	end
	for i,pin in ipairs(lightSensorPins) do
		if type(pin) == 'number' then
			LightSensor:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			LightSensor:new(pin.pin,pin)
		end
	end
	for i,pin in ipairs(DHT22Pins) do
		if type(pin) == 'number' then
			DHT22:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			DHT22:new(pin.pin,pin)
		end
	end
	for i,op in ipairs(stepperPins) do
		if type(op) == 'table' then
			StepperMotor:new(op.pin1..','..op.pin2..','..op.pin3..','..op.pin4,op)
		end
	end
	for i,pin in ipairs(servoPins) do
		if type(pin) == 'number' then
			ServorMotor:new(pin,{pin=pin})
		elseif type(pin) == 'table' then
			ServorMotor:new(pin.pin,pin)
		end
	end
	for i,op in ipairs(motorPins) do
		if type(op) == 'table' then
			Motor:new(op.pin1..','..op.pin2,op)
		end
	end

	--check for 1 wire sensors to add to the sensors table
	--only temp sensors for now
	for i,v in ipairs(scandir("/sys/bus/w1/devices",true)) do
		if v ~= "." and v ~= ".." and v ~= "w1_bus_master1" then
			TempSensor:new(v,{w_id=v})
		end
	end

	--start up higher logic objects after all required objects are loaded
	for i,op in ipairs(thermostatStartup) do
		if type(op) == 'table' then
			Thermostat:new(op.id,op)
		end
	end
	for i,op in ipairs(motionSensorStartup) do
		if type(op) == 'table' then
			MotionSensor:new(op.id,op)
		end
	end
	for i,op in ipairs(macScannerStartup) do
		if type(op) == 'string' then
			MacScanner:new(op,{id=op})
		elseif type(op) == 'table' then
			MacScanner:new(op.id,op)
		end
	end

	--for easier object lookup
	for i,v in ipairs(objects) do
		objects[v.name] = v
	end
	if c then SQLconn:close() _G.SQLconn = nil end
end

function _G.objectUpdate(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	saveObjectsInfo(conn)
	updateSiteLinks(conn)
	updateSensorLinks(conn)
	if c then SQLconn:close() _G.SQLconn = nil end
end

function _G.objectLoad(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	--retrieve saved info for all objects
	loadObjectsInfo(conn)
	if c then SQLconn:close() _G.SQLconn = nil end
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

function _G.updateSiteLinks(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	SQLconn:execute([[DROP TABLE IF EXISTS MASTERLinks;]])
	SQLconn:execute([[CREATE TABLE MASTERLinks (link TEXT);]])
	for i,link in ipairs(siteLinks) do
		SQLconn:execute("INSERT INTO MASTERLinks values('"..link.."');")
	end
	if c then SQLconn:close() _G.SQLconn = nil end
end

function _G.updateSensorLinks(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	local function addtodatabase(index,val)
		local cursor,errorString2 = SQLconn:execute(([[SELECT * FROM MasterSensors WHERE name='%s';]]):format(index))
		local row = cursor:fetch ({}, "a")
		if row then
			local status,errorString = SQLconn:execute(([[UPDATE MasterSensors SET (name="%s",loc="%s") WHERE name="%s";]]):format(index,val,index))
		else
			SQLconn:execute("INSERT INTO MasterSensors values('"..index.."','"..val.."');")
		end
		cursor:close()
	end

	SQLconn:execute([[CREATE TABLE MasterSensors (name TEXT, loc TEXT);]])
	if sensors then
		for i,sensor in ipairs(sensors) do
			addtodatabase(sensor:getName(),'temp')
		end
	end
	if DHTs then
		for i,sensor in ipairs(DHTs) do
			addtodatabase(sensor:getName()..'_h','humidity')
			addtodatabase(sensor:getName()..'_t','temp')
		end
	end
	if lightsensors then
		for i,sensor in ipairs(lightsensors) do
			addtodatabase(sensor:getName(),'light')
		end
	end
	if c then SQLconn:close() _G.SQLconn = nil end
end

function _G.removeSensorLink(senId)
	local conn = env:connect(SQLFile)
	local re = nil
	if senId then
		local cursor,errorString = SQLconn:execute(([[SELECT * FROM MasterSensors WHERE name='%s';]]):format(senId))
		local row = cursor:fetch ({}, "a")
		if row then
			local cursor,errorString = SQLconn:execute(([[DELETE FROM MasterSensors WHERE name='%s';]]):format(senId))
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

function _G.saveObjectsInfo(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	for i,tab in ipairs(objects) do
		local tabName = string.upper(tab.name)
		--SQLconn:execute([[DROP TABLE IF EXISTS LEDs;]])
		SQLconn:execute(([[CREATE TABLE %s (sID TEXT, id TEXT, name TEXT, config TEXT)]]):format(tabName))
		for i,v in ipairs(tab) do
			sID = v.sID
			local cursor,errorString = SQLconn:execute(("select * from %s where sID='%s';"):format(tabName,sID))
			if cursor then
				local row = cursor:fetch ({}, "a")
				if row then
					SQLconn:execute(([[UPDATE %s SET id='%s',name='%s',config='%s' WHERE sID='%s';]]):format(tabName,v:getID(),v:getName(),v:getConfig(),sID))
				else
					SQLconn:execute(([[INSERT INTO %s values('%s','%s','%s','%s');]]):format(tabName,sID,v:getID(),v:getName(),v:getConfig()))
				end
				cursor:close()
			end
		end
	end
	if c then SQLconn:close() _G.SQLconn = nil end
end
function _G.loadObjectsInfo(c)
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	for i,tab in ipairs(objects) do
		local tabName = string.upper(tab.name)
		for i,v in ipairs(tab) do
			sID = v.sID
			local cursor,errorString = SQLconn:execute(("select * from %s where sID='%s';"):format(tabName,sID))
			if cursor then
				local row = cursor:fetch ({}, "a")
				if row then
					local bl = loadData(row.config)
					if bl then v:setConfig(bl) end
				end
				cursor:close()
			end
		end
	end
	if c then SQLconn:close() _G.SQLconn = nil end
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
	local c
	if not _G.SQLconn then _G.SQLconn = env:connect(SQLFile) c = true else c = false end
	if SQLconn then
		local stamp = os.time(os.date("*t"))
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		if sensors then
			SQLconn:execute([[CREATE TABLE temp (id TEXT, name TEXT, stamp time, tdate date, ttime time, cel INTEGER, fah INTEGER)]])
			for i,v in ipairs(sensors) do
				local t1,t2,er = v:read()
				if not er then
					if log then
						local status,errorString = SQLconn:execute("INSERT INTO temp values('" .. v:getID() .. "','" .. v:getName() .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "','" .. t2 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2) end
				else
					if p then print(v:getID(),v:getName(),er) end
				end
			end
		end
		if DHTs then
			SQLconn:execute([[CREATE TABLE temp (id TEXT, name TEXT, stamp time, tdate date, ttime time, cel INTEGER, fah INTEGER)]])
			SQLconn:execute([[CREATE TABLE humidity (id TEXT, name TEXT, stamp time, tdate date, ttime time, hum INTEGER)]])
			for i,v in ipairs(DHTs) do
				local t1,t2 = v:read()
				if t1 then
					local t3 = (t2 * 9 / 5  + 32)
					if log then
						local status,errorString = SQLconn:execute("INSERT INTO temp values('" .. v:getID() .. "','" .. v:getName()..'_t' .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t2 .. "','" .. t3 .. "')")
						local status,errorString = SQLconn:execute("INSERT INTO humidity values('" .. v:getID() .. "','" .. v:getName()..'_h' .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2,t3) end
				else
					if p then print(v:getID(),v:getName(),'error') end
				end
			end
		end
		if lightsensors then
			SQLconn:execute([[CREATE TABLE light (id TEXT, name TEXT, stamp time, tdate date, ttime time, lightlevel INTEGER)]])
			for i,v in ipairs(lightsensors) do
				local t1,t2,er = v:read()
				if not er then
					if log then
						local status,errorString = SQLconn:execute("INSERT INTO light values('" .. v:getID() .. "','" .. v:getName() .. "','" .. stamp .. "','" .. date .. "','" .. time .. "','" .. t1 .. "')")
					end
					if p then print(v:getID(),v:getName(),t1,t2) end
				else
					if p then print(v:getID(),v:getName(),er) end
				end
			end
		end
	else
		print('sql connect error on poll')
	end
	if c then SQLconn:close() _G.SQLconn = nil end
end

local errorsTable = {}
function _G.runError(er)
	if run then
		if not er then er = "error" else logEvent('runError',er) end
		table.insert(errorsTable,er)
		if #errorsTable >= 4 then
			local log = ''
			for i,v in ipairs(errorsTable) do logs = logs..'\n'..v end
			alert('RunError, rebooting at '.. os.date() ..'!\n'..logs)
			_G.REBOOT = true
			run = false
			logEvent('runError','ERROR MAX REBOOTING!')
		end
	end
end
function _G.alert(msg)
	msg = 'An alert has been issued by '..mainID .. (msg and '!\n' .. msg or '!')
	for i,v in ipairs(users) do
		if v.email then
			sendEmail("!ALERT!", msg ,v.email)
		end
		if v.txt then
			sendEmail("!ALERT!", msg ,v.txt , true)
		end
	end
end


--t is base time in seconds to be converted
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

