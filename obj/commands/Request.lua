local Command	= require("obj.Command")

--- Request command in charge of sending and processing requests from remote nodes or masters
local Request	= Command:clone()
Request.name = "Request"
Request.keywords	= {"request"}

--- Execute the command
function Request:execute(input,user,par)
	if par == "tcp" then
		if user.node or user.master then
			return Request:subexecute(input,user,par)
		end
	end
	return false
end

function Request:subexecute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]
	if Request.orders[input2] then--This is a valid order
		return Request.orders[input2](input3,user,par)
	else
		return "That is not a vaild order."
	end
	return false
end

Request.orders = {}

Request.orders["SenDHT22"] = function(sensorID,user)
	if sensors and #sensors > 0 then
		local data = "Response SenDHT22 "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(DHTs) do
			local h,t = v:getLastRead()
			if h then
				data = ("%s,{name='%s',id='%s',h=%s,t=%s}"):format(data,v:getName(),v:getID(),h,t)
			else
				data = ("%s,{name='%s',id='%s',er='error'}"):format(data,v:getName(),v:getID())
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["SenTemp"] = function(sensorID,user)
	if sensors and #sensors > 0 then
		local data = "Response SenTemp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(sensors) do
			if not sensorID or v:getName() == sensorID then
				local t1,t2,er = v:getLastRead()
				if not er then
					data = ("%s,{name='%s',id='%s',%s,%s}"):format(data,v:getName(),v:getID(),t1,t2)
				else
					data = ("%s,{name='%s',id='%s',er='%s'}"):format(data,v:getName(),v:getID(),er)
				end
				if sensorID then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["SenLight"] = function(sensorID,user)
	if lightsensors and #lightsensors > 0 then
		local data = "Response SenLight "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(lightsensors) do
			if not sensorID or v:getName() == sensorID then
				local t1,t2,er = v:getLastRead()
				if not er then
					data = ("%s,{name='%s',id='%s',%s,'%s'}"):format(data,v:getName(),v:getName(),t1,t2)
				else
					data = ("%s,{name='%s',id='%s',er='%s'}"):format(data,v:getName(),v:getName(),er)
				end
				if sensorID then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["RlUp"] = function(relayId,user)
	if relays and #relays > 0 then
		local data = "Response RlUp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(relays) do
			if not relayId or relayId == v:getName() then
				data = ([[%s,{id='%s',reading=%s%s%s}]]):format(data,v:getName(),v:read(), v.stayOn and ", stayOn="..v.stayOn or "", v.stayOff and ", stayOff="..v.stayOff or "")
				if relayId then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["LEDUp"] = function(LEDid,user)
	if LEDs and #LEDs > 0 then
		local data = "Response LEDUp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(LEDs) do
			if not LEDid or LEDid == v:getName() then
				data = ([[%s,{id='%s',reading=%s%s%s%s}]]):format(data,v:getName(),v:read(), v.blinking and ", blinking=true" or "", v.stayOn and ", stayOn="..v.stayOn or "", v.stayOff and ", stayOff="..v.stayOff or "")
				if LEDid then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["ThUp"] = function(ThermID,user)
	if thermostats and #thermostats > 0 then
		local data = "Response ThUp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(thermostats) do
			if not ThermID or ThermID == v:getName() then
				data = ([[%s,{id='%s',config={temperature=%s,temperatureThreshold=%s,heatThreshold=%s,coolThreshold=%s,updateTime=%s,tempSensor="%s",heatingRelay="%s",coolingRelay="%s",state="%s",action="%s"}}]]):format(data,v:getID()
				,v:getTemp(),v:getTempTh(),v:getHeatTh(),v:getCoolTh(),v:getUpTime(),v:getTempSensorID(),v:getHeatRelay(),v:getCoolRelay(),v:getState(),v:getAction())
				if ThermID then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["MosUp"] = function(MosID,user)
	if motionSensors and #motionSensors > 0 then
		local data = "Response MosUp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(motionSensors) do
			if not MosID or MosID == v:getName() then
				data = ([[%s,{id='%s',config={lightSensitivity=%s,lightSensor="%s",button="%s",relay="%s",LED="%s",buzzer="%s",sensitivity=%s,timeOut=%s,state="%s",action="%s"}}]]):format(data,v:getID()
				,v:getLightSensitivity(),v:getLightSensor(),v:getButton(),v:getRelay(),v:getLED(),v:getBuzzer(),v:getSensitivity(),v:getTimeOut(),v:getState(),v:getAction())
				if MosID then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end


Request.orders["MASUp"] = function(MASID,user)
	if macScanners and #macScanners > 0 then
		local data = "Response MASUp "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		for i,v in ipairs(macScanners) do
			if not MASID or MASID == v:getName() then
				data = ([[%s,{id='%s',config=%s,macTable=%s}]]):format(data,v:getID(),table.savetoString(v.config),table.savetoString(v.macTable))
				if MASID then break end
			end
		end
		data = ("%s}|"):format(data)
	return data
	end
end



Request.orders["objects"] = function(objs,user)
	if objs then
		objs = string.gsub(objs,'[%(%)]',"")
		local words = string.Words(objs)
		objs = {}
		for i,v in ipairs(words) do
			objs[v] = true
		end
	else
		objs = {}
		for i,v in ipairs(objects) do
			objs[v.name] = true
		end
	end
	local data = ("Response objects |return {id='%s'"):format(mainID)
	if sensors and objs['sensors'] then
		data = ("%s,sensors={'void'"):format(data)
		for i,v in ipairs(sensors) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getID())
				if user.master then user.master:addSensor(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if buttons and objs['buttons'] then
		data = ("%s,buttons={'void'"):format(data)
		for i,v in ipairs(buttons) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getName())
				if user.master then user.master:addButton(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if DHTs and objs['DHTs'] then
		data = ("%s,DHTs={'void'"):format(data)
		for i,v in ipairs(DHTs) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getName())
				if user.master then user.master:addDHT(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if lightsensors and objs['lightsensors'] then
		data = ("%s,lightsensors={'void'"):format(data)
		for i,v in ipairs(lightsensors) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getName())
				if user.master then user.master:addLSensor(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if relays and objs['relays'] then
		data = ("%s,relays={'void'"):format(data)
		for i,v in ipairs(relays) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getName())
				if user.master then user.master:addRelay(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if LEDs and objs['LEDs'] then
		data = ("%s,LEDs={'void'"):format(data)
		for i,v in ipairs(LEDs) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{name='%s',id='%s'}"):format(data,v:getName(),v:getName())
				if user.master then user.master:addLED(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if thermostats and objs['thermostats'] then
		data = ("%s,thermostats={'void'"):format(data)
		for i,v in ipairs(thermostats) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{id='%s'}"):format(data,v:getID())
				if user.master then user.master:addThermostat(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if motionSensors and objs['motionSensors'] then
		data = ("%s,motionSensors={'void'"):format(data)
		for i,v in ipairs(motionSensors) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{id='%s'}"):format(data,v:getID())
				if user.master then user.master:addMotionSensor(v) end
			end
		end
		data = ("%s}"):format(data)
	end
	if macScanners and objs['macScanners'] then
		data = ("%s,macScanners={'void'"):format(data)
		for i,v in ipairs(macScanners) do
			if not user.node or not v:isNode(user.node) then
				data = ("%s,{id='%s',macTable=%s,foundMacs=%s,lostMacs=%s,knownMacs=%s}"):format(data,v:getID(),table.savetoString(v.macTable),table.savetoString(v.foundMacs),table.savetoString(v.lostMacs),table.savetoString(v.knownMacs))
				if user.master then user.master:addMacScanner(v) end
			end
		end
		data = ("%s}"):format(data)
	end

	data = ("%s}|"):format(data)
	return data
end

return Request
