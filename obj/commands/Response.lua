local Command	= require("obj.Command")
local RemoteStepperMotors = require("obj.Remote_StepperMotor")
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

Response.orders["objectUpdate"] = function(input,user)
	if user.node then
		local data = string.match(input, '|(.+)|')
		if data then
			local loadedData = loadData(data)
			if loadedData then
				for i,v in ipairs(loadedData) do
					if v.id and v.config then
						local obj = user.node.objectIDs[v.id]
						if obj then
							obj.lastup = tonumber(loadedData.stamp)
							obj:setConfig(v.config)
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
			local objects = loadData(data)
			if objects then
				if objects.stepperMotors then
					for i,v in ipairs(objects.stepperMotors) do
						if type(v) == "table" then
							RemoteStepperMotors:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.sensors then
					for i,v in ipairs(objects.sensors) do
						if type(v) == "table" then
							RemoteSensor:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.buttons then
					for i,v in ipairs(objects.buttons) do
						if type(v) == "table" then
							RemoteButton:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.DHT22s then
					for i,v in ipairs(objects.DHT22s) do
						if type(v) == "table" then
							RemoteDHT22:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.lightsensors then
					for i,v in ipairs(objects.lightsensors) do
						if type(v) == "table" then
							RemoteLightSensor:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.relays then
					for i,v in ipairs(objects.relays) do
						if type(v) == "table" then
							RemoteRelay:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.LEDs then
					for i,v in ipairs(objects.LEDs) do
						if type(v) == "table" then
							RemoteLED:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.thermostats then
					for i,v in ipairs(objects.thermostats) do
						if type(v) == "table" then
							RemoteThermostat:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.motionSensors then
					for i,v in ipairs(objects.motionSensors) do
						if type(v) == "table" then
							RemoteMotionSensor:new(v.id,v.name,v.config,user.node)
						end
					end
				end
				if objects.macScanners then
					for i,v in ipairs(objects.macScanners) do
						if type(v) == "table" then
							RemoteMacAddressScanner:new(v.id,v.name,v.config,v.foundMacs,v.lostMacs,user.node)
							--RemoteMacAddressScanner:new(v.id,v.name,{},v.macTable,v.foundMacs,v.lostMacs,v.knownMacs,user.node)
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
