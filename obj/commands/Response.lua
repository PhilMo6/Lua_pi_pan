local Command	= require("obj.Command")
local RemoteButton = require("obj.Remote_Button")
local RemoteDHT22 = require("obj.Remote_DHT22")
local RemoteSensor = require("obj.Remote_1w_TempSensor")
local RemoteLightSensor = require("obj.Remote_LightSensor")
local RemoteRelay = require("obj.Remote_Relay")
local RemoteLED = require("obj.Remote_LED")
local RemoteThermostat = require("obj.Remote_Thermostat")
local RemoteMotionSensor  = require("obj.Remote_MotionSensor")
local RemoteMacAddressScanner  = require("obj.Remote_MacAddressScanner")

--- Response command in charge of reciveing and processing responses from remote nodes or masters
local Response	= Command:clone()
Response.name = "Response"
Response.keywords	= {"response"}

--- Execute the command
function Response:execute(input,user,par)
	if par == "tcp" then
		if user.node or user.master then
			return Response:subexecute(input,user,par)
		end
	end
	return false
end

function Response:subexecute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]
	if Response.orders[input2] then--This is a valid order
		return Response.orders[input2](input,user)
	else
		return "That is not a vaild order."
	end
	return false
end



Response.orders = {}

Response.orders["SenDHT"] = function(input,user)
	local data = string.match(input, '|(.+)|')
	if data then
		local data = boxLoad(data)
		if data then
			for i,v in ipairs(data) do
				if type(v) == "table" then
					local sensor = user.node.DHTs[v.id]
					if sensor and not v.er then
						sensor.lastHRead = v.h
						sensor.lastTRead = v.t
						sensor.error = nil
					elseif sensor then
						sensor.error = (sensor.error and sensor.error + 1 or 1)
						if sensor.error == 3 then sensor:removeSensor() end
					end
				end
			end
		end
	end
	return false
end

Response.orders["SenTemp"] = function(input,user)
	local data = string.match(input, '|(.+)|')
	if data then
		local temp = boxLoad(data)
		if temp then
			for i,v in ipairs(temp) do
				if type(v) == "table" then
					local sensor = user.node.sensors[v.id]
					if sensor and not v.er then
						sensor:updateLastRead(v[1])
						sensor.error = nil
					elseif sensor then
						sensor.error = (sensor.error and sensor.error + 1 or 1)
						if sensor.error == 3 then sensor:removeSensor() end
					end
				end
			end
		end
	end
	return false
end

Response.orders["SenLight"] = function(input,user)
	local data = string.match(input, '|(.+)|')
	if data then
		local temp = boxLoad(data)
		if temp then
			for i,v in ipairs(temp) do
				if type(v) == "table" then
					local sensor = user.node.lightsensors[v.id]
					if sensor and not v.er then
						sensor:updateLastRead(v[1])
					elseif sensor then
						sensor.lastError = v.er
					end
				end
			end
		end
	end
	return false
end

Response.orders["RlUp"] = function(input,user)
	if user.node and user.node.relays then
		local data = string.match(input, '|(.+)|')
		if data then
			local relayData = boxLoad(data)
			if relayData then
				for i,v in ipairs(relayData) do
					if v.id then
						local relay = user.node.relays[v.id]
						if relay then
							relay.lastup = tonumber(relayData.stamp)
							relay.lastRead = v.reading
							relay.stayOn = v.stayOn
							relay.stayOff = v.stayOff
						end
					end
				end
			end
		end
	end
	return false
end

Response.orders["LEDUp"] = function(input,user)
	if user.node and user.node.LEDs then
		local data = string.match(input, '|(.+)|')
		if data then
			local LEDData = boxLoad(data)
			if LEDData then
				for i,v in ipairs(LEDData) do
					if v.id then
						local LED = user.node.LEDs[v.id]
						if LED then
							LED.lastup = tonumber(LEDData.stamp)
							LED.lastRead = v.reading
							LED.blinking = v.blinking
							LED.stayOn = v.stayOn
							LED.stayOff = v.stayOff
						end
					end
				end
			end
		end
	end
	return false
end

Response.orders["ThUp"] = function(input,user)
	if user.node and user.node.thermostats then
		local data = string.match(input, '|(.+)|')
		if data then
			local thermData = boxLoad(data)
			if thermData then
				for i,v in ipairs(thermData) do
					if v.id and v.config then
						local thermostat = user.node.thermostats[v.id]
						if thermostat then
							thermostat.lastup = tonumber(thermData.stamp)
							thermostat:setConfig(v.config)
						end
					end
				end
			end
		end
	end
	return false
end

Response.orders["MosUp"] = function(input,user)
	if user.node and user.node.motionSensors then
		local data = string.match(input, '|(.+)|')
		if data then
			local mosData = boxLoad(data)
			if mosData then
				for i,v in ipairs(mosData) do
					if v.id and v.config then
						local mos = user.node.motionSensors[v.id]
						if mos then
							mos.lastup = tonumber(mosData.stamp)
							mos:setConfig(v.config)
						end
					end
				end
			end
		end
	end
	return false
end

Response.orders["MASUp"] = function(input,user)
	if user.node and user.node.macScanners then
		local data = string.match(input, '|(.+)|')
		if data then
			local MASData = boxLoad(data)
			if MASData then
				for i,v in ipairs(MASData) do
					if v.id and v.config then
						local MAS = user.node.macScanners[v.id]
						if MAS then
							MAS.lastup = tonumber(MASData.stamp)
							MAS:setConfig(v.config,v.macTable,v.foundMacs,v.lostMacs)
						end
					end
				end
			end
		end
	end
	return false
end


Response.orders["objects"] = function(input,user)
	if user.node then
		local data = string.match(input, '|(.+)|')
		if data then
			local objects = boxLoad(data)
			if objects then
				if objects.sensors then
					for i,v in ipairs(objects.sensors) do
						if type(v) == "table" then
							RemoteSensor:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.buttons then
					for i,v in ipairs(objects.buttons) do
						if type(v) == "table" then
							RemoteButton:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.DHTs then
					for i,v in ipairs(objects.DHTs) do
						if type(v) == "table" then
							RemoteDHT22:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.lightsensors then
					for i,v in ipairs(objects.lightsensors) do
						if type(v) == "table" then
							RemoteLightSensor:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.relays then
					for i,v in ipairs(objects.relays) do
						if type(v) == "table" then
							RemoteRelay:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.LEDs then
					for i,v in ipairs(objects.LEDs) do
						if type(v) == "table" then
							RemoteLED:new(v.id,v.name,user.node)
						end
					end
				end
				if objects.thermostats then
					for i,v in ipairs(objects.thermostats) do
						if type(v) == "table" then
							RemoteThermostat:new(v.id,{},user.node)
						end
					end
				end
				if objects.motionSensors then
					for i,v in ipairs(objects.motionSensors) do
						if type(v) == "table" then
							RemoteMotionSensor:new(v.id,{},user.node)
						end
					end
				end

				if objects.macScanners then
					for i,v in ipairs(objects.macScanners) do
						if type(v) == "table" then
							RemoteMacAddressScanner:new(v.id,{},v.macTable,v.foundMacs,v.lostMacs,v.knownMacs,user.node)
						end
					end
				end


				updateSensorLinks()
			end
		end
	end
	return false
end


return Response
