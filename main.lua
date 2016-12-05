
package.path = package.path .. ";./?.lua;/usr/share/luajit-2.0.0/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua"--added for use with raspberry pi

require("preload")
require("socket")
_G.bit32 = require("bit32")
--require("logging")
--require("logging.file")
--require("logging.console")
require("ext.table")
require("ext.string")
require("ext.math")
_G.Event = require("obj.Event")--Event object is used more then any other so load it globaly

_G.RPIO = require "rpio"
local Server = require "obj.Server"
--modules
require("Config")
require("Mail")
require("Scheduler")
require("CommandParser")


print('Starting Lua pi Pan')
--do setup needed to run Lua pi pan
local luasql = require "luasql.sqlite3"
_G.env = luasql.sqlite3() -- Create a database environment object
local conn = env:connect(SQLFile) -- Open a database file

print('Adding objects')
loadObjects(conn)--sets up all objects for use
print('Loading objects info')
objectLoad(conn)--loads any previus names/configs into objects
print('Updating objects info')
objectUpdate(conn)--updates info to add any new objects
conn:close() -- Close the database file connection object

--do 4 reads on all sensors to prep them for accurate readings
--weed out non functional sensors
if sensors then
	for i,v in ipairs(sensors) do
		local erC = 0
		for i=1,4 do
			local t1,t2,er = v:read()
			if er then erC = erC + 1 end
		end
		if erC == 4 then sensors[i] = nil sensors[v:getID()] = nil sensors[v:getName()] = nil v = nil end
	end
end


--send message to main email to clear command buffer
local msg = ("Startup time:%s\n"):format(os.date('%c'))
for i,v in ipairs(objects) do
	msg = ("%s %s:%s"):format(msg,string.firstToUpper(v.name),#v)
end
sendMessage("Startup", msg ,mainEmail)
print(msg)
msg = nil
pollSensors(true,true)

--add main events to be queued on start to this table
--these are the events the run all the programs functionality
local mainEvents = {}

--[[Example events showing some basic possible functionality
local mainEvents = {
	Event:new(function()--button event
		if buttons then
			for i,v in ipairs(buttons) do v:read() end
			local b1,b2 = nil
			if buttons[1] and not SHUTTINGDOWN then--button1 toggles fanHigh and windowClosed flags
				if buttons[1]:getState() == 'pressed' then
					b1 = true
					if thermostats and thermostats['room'] then
						thermostats['room']:setTemp(thermostats['room']:getTemp() - 1)
						thermostats['room']:runLogic()
						print(thermostats['room']:getStatus())
					end
					if LEDs[1] then LEDs[1]:on() end
					sleep(.5)
					if LEDs[1] then LEDs[1]:off() end
				end
			end
			if buttons[2] and not SHUTTINGDOWN then--button2 mutes all buzzers
				if buttons[2]:getState() == 'pressed' then
					b2 = true
					if thermostats and thermostats['room'] then
						thermostats['room']:setTemp(thermostats['room']:getTemp() + 1)
						thermostats['room']:runLogic()
						print(thermostats['room']:getStatus())
					end
					if LEDs[2] then LEDs[2]:on() end
					sleep(.5)
					if LEDs[2] then LEDs[2]:off() end
				end
			end
			if buttons[3] and not SHUTTINGDOWN then--fan on off toggle
				if buttons[3]:getState() == 'pressed' then
					if relays[1] then relays[1]:toggle() sleep(.5) end
				end
			elseif buttons[3] and SHUTTINGDOWN then--if shutdown in progress then set reset flag
				if buttons[3]:getState() == 'pressed' then
					resetC = (resetC or 0) + 1
					if resetC > 3 then
						print('Reseting!')
						_G.RESET = true
						sleep(.5)
					end
				end
			end
			if buttons[4] and not SHUTTINGDOWN then--print status
				if buttons[4]:getState() == 'pressed' then
					print('')
					print(getStatus())
					print('')
					sleep(.5)
				end
			elseif  buttons[4] and SHUTTINGDOWN then--if shutdown in progress then stop shutdown
				if buttons[4]:getState() == 'pressed' then
					resetC = (resetC or 0) + 1
					if resetC > 3 then
						Scheduler:dequeue(SHUTTINGDOWN)
						_G.SHUTTINGDOWN = nil
						_G.RESET = nil
						print('Shutdown halted!')
						sleep(.5)
					end
				end
			end

			if buttonIDs[14] and not SHUTTINGDOWN then
				if buttonIDs[14]:getState() == 'pressed' then
					if thermostats and thermostats['room'] then
						thermostats['doghouse']:setTemp(thermostats['doghouse']:getTemp() - 1)
						thermostats['doghouse']:runLogic()
						print(thermostats['doghouse']:getStatus())
					end
					sleep(.5)
				end
			end
			if buttonIDs[16] and not SHUTTINGDOWN then
				if buttonIDs[16]:getState() == 'pressed' then
					if thermostats and thermostats['room'] then
						thermostats['doghouse']:setTemp(thermostats['doghouse']:getTemp() + 1)
						thermostats['doghouse']:runLogic()
						print(thermostats['doghouse']:getStatus())
					end
					sleep(.5)
				end
			end

			if b1 and b2 and not SHUTTINGDOWN then--if both buttons are pressed shut down
				if buzzers[1] then buzzers[1]:test() end
				_G.SHUTTINGDOWN = Event:new(function()	run = false end, 15, false)
				Scheduler:queue(SHUTTINGDOWN)
				print('Shutdown in 15 seconds!')
				sleep(.5)
			end
		end
	end, .1, true, 0)
	,
	Event:new(function()--alarm!!!!!!!!!!!!!
		if macScanners and macScanners[1] and macScanners[1].started and not macScanners[1]:isID('my phone') then
			if motionSensors and motionSensors[1] and motionSensors[1]:checkMotion() then
				if buzzers[1] then
					buzzers[1]:test()
					sendMessage("Room Alarm", 'Room alarm at '.. os.date() ,'philipmowrey@gmail.com')
				end
			end
		end
	end, 20, true, 0)
	,
	Event:new(function()--if battery relay is set power cycle battery for 5 min every hour
		if relays and relays['battery'] then
			relays['battery']:on()
			Scheduler:queue(Event:new(function() relays['battery']:off() end, 60*5, false))
		end
	end, 60*60, true, 0)
	,
	Event:new(function()--check email for any commands not yet parsed and if found find and run command if available.
		local msg = receiveMessage()
		if msg then
			local date = msg:date()
			if lastCommand ~= date then
				lastCommand = date
				local command = msg:subject()
				local user = msg:from()
				local _,_,email = string.find(user,"<(.+)>")
				print(('Email Command received: %s \nFrom: %s%s'):format(command,user,(email and " " ..email or "")))
				if user ~= mainEmail then
					local s,r,com = CommandParser:parse(command,(email or user),'mail')
					if s then
						sendMessage("Command accepted", r or "The command " .. com.name .. " has been executed." ,(email or user))
					else
						sendMessage("Command failed", command .. " is not a valid command." ,(email or user))
					end
				end
			end
		end
	end, mailCheckTime, true, 0)
}]]



for i,v in ipairs(mainEvents) do--schedule all main events
	Scheduler:queue(v)
end
mainEvents = nil


if tcpPort then
	print('opening tcp server')
	_G.runningServer = Server:new()
	local _, err = runningServer:host(tcpPort)
	if err then print(err,"!will try reset in 1 min!") _G.runningServer = nil
		Scheduler:queue(Event:new(function()--reset system after 1 min to allow old connections to close
		_G.SHUTTINGDOWN = Event:new(function()	run = false end, 15, false)
		Scheduler:queue(SHUTTINGDOWN)
		_G.RESET = true
	end, timeM(1,'m'), false))
	else
		print('opened')
		if #masterList > 0 then
			print('connecting to masters')
			runningServer:connectMasters()
		end
	end
end
if startsite then
	local handle = io.popen("pidof mako")
	local result = tonumber(handle:read("*a"))
	handle:close()
	local exe = "sudo mako -l::site &"
	if result then exe = "sudo kill -9 " .. result .. ";" .. exe end
	os.execute(exe)
end



print('Up and running')
_G.lastCommand = false
_G.run = true
--main loop
while run == true do
	socket.select(nil,nil,getFrequency())
	Scheduler:poll(socket.gettime())
end
print('Stopping system')
--if main loop breaks clean up anything left over
if runningServer then runningServer:close() print('tcp closed') end
if cursor then cursor:close() end
if conn then conn:close() end
if env then env:close() end
local cleanup = RPIO()
cleanup()
if PWMstop then PWMstop() end
collectgarbage()

if startsite then
	local handle = io.popen("pidof mako")
	local result = tonumber(handle:read("*a"))
	handle:close()
	if result then os.execute("sudo kill -9 " .. result .. "&") end
end

print('System shut down')
local handle = io.popen("pidof lua")
local result = tonumber(handle:read("*a"))
handle:close()
local exe = ""
if result then
	exe = "sudo kill -9 " .. result .. "&"
end
if RESET then
print('Restarting')
	exe = exe.."sudo lua main.lua"
end
os.execute(exe)
