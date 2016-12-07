local Cloneable			= require("obj.Common")
local Sensor			= Cloneable:clone()
local Button = require("obj.Button")
--[[
	Object module for PIR motion sensors such as https://www.adafruit.com/product/189
	The pin provided is hooked up to the PIR sensor and used to generate a button object that changes the motions sensors state.
	If no pin is provided you can set a pre generated button though the options table or after the module is loaded with a command.
	You can also set a light sensor so it only turns on when dark with addjustable sensitivity.
	If set turns on relay, LED, and or buzzer upon activation.
	You can adjust sensitivity for to change how much activity will set off trigger.
	Setting timeout will change how long objects will stay on after motion has stoppped being detected.
]]

Sensor.location = 'motionSensors'
Sensor.config = {}--default config
Sensor.config.lightSensor 		= "lightSensor"
Sensor.config.lightSensitivity 	= 300
Sensor.config.button 			= "motionSwitch"
Sensor.config.relay  			= "motionLight"
Sensor.config.LED	   			= "motionLED"
Sensor.config.buzzer			= "alarm"
Sensor.config.sensitivity 		= 35
Sensor.config.timeOut			= 30


function Sensor:setup(options)
	local pin = options.pin
	local button
	if pin then
		button = Button:new(pin,{pin=pin,edge=1})
	end
	self.config.lightSensor 		= options and options.lightSensor or Sensor.config.lightSensor
	self.config.lightSensitivity	= options and options.lightSensitivity or Sensor.config.lightSensitivity
	self.config.button 				= options and options.button or button and button:getID() or Sensor.config.button
	self.config.relay  				= options and options.relay or Sensor.config.relay
	self.config.LED	   				= options and options.LED or Sensor.config.LED
	self.config.buzzer		 		= options and options.buzzer or Sensor.config.buzzer
	self.config.sensitivity 		= options and options.sensitivity or Sensor.config.sensitivity
	self.config.timeOut		 		= options and options.timeOut or Sensor.config.timeOut
	self.config.state 				= (options and options.state or 'active')
	self.config.action 				= 'standby'

	self.checks = 0

	local sen = self
	Scheduler:queue(Event:new(function()
		sen.checkEvent = Event:new(function()--trigger event that runs the sensors logic
			sen:runLogic()
		end, .1, true, 0)
		Scheduler:queue(sen.checkEvent)
	end, 15, false))
end


function Sensor:runLogic()
	if self:getAction() == 'on' then
		if self:checkMotion() and (self:getState() == 'on' or self:checkLight()) then
			self.onTime = os.time()
		elseif (self.onTime + self:getTimeOut()) < os.time() then
			self:setAction('standby')
		end
	elseif self:getState() == 'active' or self:getState() == 'on' then
		if self:getState() == 'on' or self:checkLight() then
			if self:checkMotion() then
				if self.checks >= self:getSensitivity() then
					self:setAction('on')
				else
					self.checks = self.checks + 2
				end
			elseif self.checks > 0 then
				self.checks = self.checks - 1
			end
		end
	end
end

function Sensor:checkLight()
	if lightsensors and lightsensors[self:getLightSensor()] then
		local lightLevel = lightsensors[self:getLightSensor()]:getLastRead()
		if lightLevel > self:getLightSensitivity() then
			return true
		else
			return false
		end
	else
		return true
	end
	return false
end

function Sensor:checkMotion()
	if buttons and buttons[self:getButton()] then
		return (buttons[self:getButton()]:read() == 1 and true or false)
	else
		return false
	end
	return false
end


function Sensor:setState(state)
	local states = {
	['active']=function()
		self:setAction()
		if relays and relays[self:getRelay()] then
			relays[self:getRelay()]:off()
		end
		if LEDs and LEDs[self:getLED()] then
			LEDs[self:getLED()]:off()
		end
		if buzzers and buzzers[self:getBuzzer()] then
			buzzers[self:getBuzzer()]:off()
		end
	end,
	['on']=function()
		self:setAction()
		if relays and relays[self:getRelay()] then
			relays[self:getRelay()]:off()
		end
		if LEDs and LEDs[self:getLED()] then
			LEDs[self:getLED()]:off()
		end
		if buzzers and buzzers[self:getBuzzer()] then
			buzzers[self:getBuzzer()]:off()
		end
	end,
	['off']=function()
		self:setAction()
		if relays and relays[self:getRelay()] then
			relays[self:getRelay()]:off()
		end
		if LEDs and LEDs[self:getLED()] then
			LEDs[self:getLED()]:off()
		end
		if buzzers and buzzers[self:getBuzzer()] then
			buzzers[self:getBuzzer()]:off()
		end
	end
	}
	if not state then state = 'off' end
	if states[state] and self.config.state ~= state then
		self.config.state = state
		if type(states[state]) == "function" then
			states[state]()
		end
		self:runLogic()
		self:updateMasters()
		logEvent(self:getName(),self:getName() .. ' state:' .. state)
	end
end

function Sensor:setAction(action)
	local states = {['on']=function()
		self.onTime = os.time()
		self.checks = 0
		if relays and relays[self:getRelay()] then
			relays[self:getRelay()]:on()
		end
		if LEDs and LEDs[self:getLED()] then
			LEDs[self:getLED()]:on()
		end
		if buzzers and buzzers[self:getBuzzer()] then
			buzzers[self:getBuzzer()]:on()
		end
	end,
	['standby']=function()
		self.checks = 0
		if relays and relays[self:getRelay()] then
			relays[self:getRelay()]:off()
		end
		if LEDs and LEDs[self:getLED()] then
			LEDs[self:getLED()]:off()
		end
		if buzzers and buzzers[self:getBuzzer()] then
			buzzers[self:getBuzzer()]:off()
		end
	end}
	if not action then action = 'standby' end
	if states[action] and self.config.action ~= action then
		self.config.action = action
		if type(states[action]) == "function" then
			states[action]()
		end
		self:updateMasters()
		logEvent(self:getName(),self:getName() .. ' action:' .. action)
	end
end

function Sensor:toggle()
	logEvent(self:getName(),self:getName() .. ' toggle')
	if self:getState() == 'active' then
		self:setState('on')
		return 'on'
	elseif self:getState() == 'off' then
		self:setState('active')
		return 'active'
	elseif self:getState() == 'on' then
		self:setState('off')
		return 'off'
	else
		self:setState('off')
		return 'off'
	end
end

function Sensor:getState()
	return self.config.state or 'off'
end

function Sensor:getAction()
	return self.config.action or 'standby'
end

function Sensor:setLightSensor(sensorID)
	self.config.lightSensor = sensorID
	logEvent(self:getName(),self:getName() .. ' lightSensor:'..sensorID)
	self:updateMasters()
end

function Sensor:getLightSensor()
	return self.config.lightSensor
end

function Sensor:setLightSensitivity(amt)
	if amt <= 0 then amt = 300 end
	self.config.lightSensitivity = amt
	logEvent(self:getName(),self:getName() .. ' setLightSensitivity:'..amt)
	self:updateMasters()
end

function Sensor:getLightSensitivity()
	return self.config.lightSensitivity
end

function Sensor:setButton(buttonID)
	self.config.button = buttonID
	logEvent(self:getName(),self:getName() .. ' setButton:'..buttonID)
	self:updateMasters()
end

function Sensor:getButton()
	return self.config.button
end

function Sensor:setRelay(relayID)
	self.config.relay = relayID
	logEvent(self:getName(),self:getName() .. ' setRelay:'..relayID)
	self:updateMasters()
end

function Sensor:getRelay()
	return self.config.relay
end

function Sensor:setLED(LEDID)
	self.config.LED = LEDID
	logEvent(self:getName(),self:getName() .. ' setLED:'..LEDID)
	self:updateMasters()
end

function Sensor:getLED()
	return self.config.LED
end

function Sensor:setBuzzer(buzzerID)
	self.config.buzzer = buzzerID
	logEvent(self:getName(),self:getName() .. ' setBuzzer:'..buzzerID)
	self:updateMasters()
end

function Sensor:getBuzzer()
	return self.config.buzzer
end

function Sensor:setSensitivity(amt)
	if amt <= 0 then amt = 5 end
	if amt ~= self.config.sensitivity then
		self.config.sensitivity = amt
		logEvent(self:getName(),self:getName() .. ' setSensitivity:'..amt)
		self:updateMasters()
	end
end

function Sensor:getSensitivity()
	return self.config.sensitivity
end

function Sensor:setTimeOut(amt)
	if amt <= 0 then amt = .5 end
	self.config.timeOut = amt
	logEvent(self:getName(),self:getName() .. ' setTimeOut:'..amt)
	self:updateMasters()
end

function Sensor:getTimeOut()
	return self.config.timeOut
end

function Sensor:getHTMLcontrol()
	local name = self:getName()
	return ('<div style="font-size:15px">%s %s <br> %s %s Sensitivity <br> %s %s Light Sensitivity <br> %s %s TimeOut <br> %s %s <br> %s %s <br> %s <br>%s</div>'):format(
	([[<button style="font-size:15px" onclick="myFunction('Mos %s stat')">Status</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s toggle')">Toggle</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sUp','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sDown','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s lsUp','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s lsDown','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s ToUp','%s')">+</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s ToDown','%s')">-</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sLS','%s')">set Light Sensor</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sB','%s')">Set Button</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sR','%s')">Set Relay</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sL','%s')">Set LED</button >]]):format(name,name),
	([[<button style="font-size:15px" onclick="myFunction('Mos %s sBz','%s')">Set Buzzer</button >]]):format(name,name),
	([[<form id="%s"> Set To:<input type="text" name='com'></form>]]):format(name)
	)
end

function Sensor:getStatus()
	local status = ""
	for i,v in pairs(self.config) do
		local ty = type(v)
		status = string.format([[%s
%s:%s]],status,i,(ty == 'string' and v or ty == 'number' and v or ty == 'boolean' and (v == true and 'true' or 'false') ))
	end
	return string.format("%s%s",self:toString(),status)
end

--- Stringifier for Cloneables.
function Sensor:toString()
	return string.format("[MotionSensor] %s %s %s %s",self:getID(),self:getName(),self:getState(),self:getAction())
end

return Sensor
