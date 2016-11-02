local Cloneable			= require("obj.baseObj")
local Button			= Cloneable:clone()

--[[
	This is the base button object used for capacitive multi-button pins.
	button layout was gotten from
	http://www.instructables.com/id/RaspberryPi-Multiple-Buttons-On-One-Digital-Pin/
	some minor tweaks where done such as using 2 1uf capacitors instead of just 1 to
	get better resolution of button presses but otherwise I used the same setup.
	!This is a high processer use object so use with care!
]]

function Button:initialize(pin,buttonCount)
	if not _G.buttons then  _G.buttons = {name='buttons'} _G.buttonIDs ={} table.insert(objects,buttons) objects["buttons"] = buttons end
	if not buttons['Button_'..pin] then
		self.config = {
			buttonCount = buttonCount,
			buttons={}
		}
		self:setID(pin)
		self:setName('Button_'..pin)
		table.insert(buttons,self)
		self:calibrate()
	end
end

function Button:getHTMLcontrol()
	return ('%s'):format(
	([[<button onclick="myFunction('button %s press')">Press</button >]]):format(self:getName())
	)
end

function Button:setID(id)
	if self.config.id then buttonIDs[self.config.id] = nil logEvent(self:getName(),self:getName() .. ' setID:'..id ) end
	self.config.id = id
	buttonIDs[self.config.id] = self
end

function Button:setName(name)
	if self.config.name then buttons[self.config.name] = nil logEvent(self:getName(),self:getName() .. ' setName:'..name ) end
	self.config.name = name
	buttons[self.config.name] = self
end

function Button:calibrate()
	local pin = self:getID()
	local function getRead()
		local reading = 0
		GPIO.setup{
			   channel=pin,
			   direction=GPIO.OUT,
			   pull_up_down = false,
			}
		GPIO.output(pin, GPIO.LOW)
		sleep(.2)
		local time1 = socket:gettime()*1000
		GPIO.setup{
			   channel=pin,
			   direction=GPIO.IN,
			   pull_up_down = false,
			}
		while GPIO.input(pin) == GPIO.LOW do
			reading = reading + 1
			if reading >= 200000 then return math.round(socket:gettime()*1000 - time1,1),true end
		end
		return math.round(socket:gettime()*1000 - time1,1)
	end

	local lastRead = 0
	print('Prepairing to calibrate, dont push any buttons until ready!')
	for _=1,10 do
		local r = getRead()
		if r > lastRead then lastRead = r end
	end
	self.config.buttons = {[0]=lastRead}
	sleep(2)
	for i=1,self.config.buttonCount do
		print(('Press and hold button number %s'):format(i))
		local rd
		local count = 0
		while true do
			rd = getRead()
			print(count,lastRead)
			if (rd + 1) < lastRead then count = count + 1 else count = (count > 0 and count - 1 or 0) end
			if count > 5 then break end
		end
		self.config.buttons[i] = rd
		lastRead = rd
		print(rd,lastRead,'Release button!\nPrepairing for next button')
		sleep(2)
	end
	for i,v in ipairs(self.config.buttons) do
		print(i,v)
	end
	print('done')
end

function Button:readO()

	local pin = self:getID()
	local function getRead()
		local reading = 0
		GPIO.setup{
			   channel=pin,
			   direction=GPIO.OUT,
			   pull_up_down = false,
			}
		GPIO.output(pin, GPIO.LOW)
		sleep(.2)
		local time1 = socket:gettime()*1000
		GPIO.setup{
			   channel=pin,
			   direction=GPIO.IN,
			   pull_up_down = false,
			}
		while GPIO.input(pin) == GPIO.LOW do
			reading = reading + 1
			if reading >= 200000 then return math.round(socket:gettime()*1000 - time1,1),nil,true end
		end
		local re = math.round(socket:gettime()*1000 - time1,1)
		local bc = #self.config.buttons
		local button
		while bc > 0 do
			if re <= self.config.buttons[bc] then button = bc break end
			bc = bc - 1
		end
		return re,button
	end
	local re,button = getRead()
	GPIO.setup{
		channel=pin,
		direction=GPIO.IN,
		pull_up_down = GPIO.PUD_DOWN,
	}
	if self.lastRead ~= button and button ~= nil then
		local r2,b2 = getRead()
		if button == b2 then
			self.lastRead = button
			return true,button
		end
	elseif self.lastRead == button then
		return true,button
	else
		self.lastRead = nil
	end

	return false
end

function Button:press(f,client)
	if client then if client.master then client = client.master elseif client.node then client = client.node end end
	if not self.pressed then
		self.readO = function()
			self.readO = Cloneable.readO
			self.lastRead = nil
			self.pressed = nil
			logEvent(self:getName(),self:getName() .. ' press:pressed')
			if self.masters then
				for i,v in ipairs(self.masters) do
					if v ~= client then v:send(([[button %s_%s press]]):format(self:getName(),mainID)) end
				end
			end
			return true end
		self.pressed = true
		return true
	end
	return false
end


--- Stringifier for Cloneables.
function Button:toString()
	return string.format("[Button] %s %s %s",self:getID(),self:getName(),(self:readO() == true and 'pressed' or 'not pressed'))
end

return Button
