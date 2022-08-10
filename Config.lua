
--[[
	config settings that determine the functionality of the program.
]]

local Config = {}
Config.mainID 						= "IDhere"
Config.homeDirectory 				= '/home/pi/Lua_pi_pan'--if installed elsewhere change this
Config.masterList					= {} --example:{{id = 'room',ip = '192.168.1.149',port = 9696}}
--when adding a node to the node list you may set an objects table that defines what objects a master will ask a given node for.
Config.nodeList 					= {}--example:{{id = 'node1',ip = '192.168.1.111',port = 9696}}
Config.mainEmail 					= false--'YourEmailHere@gmail.com' if false will not try sending mail.
Config.mainEmailPass				= 'YourEmailPasswordHere'
Config.users						= {{email="",txt=""}--{'5555555555@vtext.com'}


Config.SQLFile						= "/home/pi/luaTest.db"
Config.sensorUpdateTime 			= 30--how often do sensors update
Config.sensorLogTime 				= 60*5--how often do sensors have their data logged into sql database
Config.mailCheckTime 				= 60--if setup how often does mail get checked for commands
--pins are assigned by gpio number
--see modules at obj/"name".lua for options
Config.lightSensorPins				= {}--pinValue
Config.LEDPins 						= {}--pinValue
Config.RBG_LEDPins 					= {}--tableValue containing 3 pins
Config.buzzerPins 					= {}--pinValue
Config.buttonPins 					= {}--pinValue or table with pinValue and options. options are pin and edge
Config.M_buttonPins 				= {}--table value containing 1 pin and number of buttons
Config.relayPins					= {}--pinValue
Config.DHT22Pins					= {}--pinValue
Config.stepperPins					= {}--table value containing 4 pins
Config.servoPins					= {}--pinValue
Config.motorPins					= {}--table value containing 2 pins and optional pmw setting
Config.thermostatStartup			= {}--table value containing id and optional config table
Config.motionSensorStartup			= {}--table value containing id, sensor pin, and optional config table
Config.macScannerStartup			= {}--stringValue or tableValue containing id and other options
--[[examples:WARNING DO NOT SET ANY GIVEN PIN ON MORE THEN 1 OBJECT
Config.lightSensorPins				= {15}--pinValue
Config.LEDPins 						= {17,27}--pinValue
Config.RBG_LEDPins 					= {{pinR=13,pinB=12,pinG=10}}--tableValue containing 3 pins 
Config.buzzerPins 					= {22}--pinValue
Config.buttonPins 					= {20,{pin=11,edge=0}}--pinValue or table with pinValue and options. options are pin and edge
Config.M_buttonPins 				= {}--table value containing 1 pin and number of buttons
Config.relayPins					= {16}--pinValue
Config.DHT22Pins					= {21}--pinValue
Config.stepperPins					= {{pin1=20,pin2=21,pin3=24,pin4=25}}--table value containing 4 pins
Config.servoPins					= {}--pinValue
Config.motorPins					= {}--table value containing 2 pins and optional pmw setting
Config.thermostatStartup			= {{'room'},{'doghouse',{tempSensor="doghouse",heatingRelay='doghouseHeater',coolingRelay='none',state='off'}}}--table value containing id and optional config table
Config.motionSensorStartup			= {{'test',18}}--table value containing id, sensor pin, and optional config table
Config.macScannerStartup			= {"macScanner"}--stringValue or tableValue containing id and other options
]]

Config.tcpPort						= 9696
Config.startsite 					= false --really only master nodes need to start a site so the default is false
Config.siteLinks					= {'dashboard','controls','graphs','status','events'}--These are the links that will be displyed by the site.

for i,v in ipairs(Config.masterList) do Config.masterList[v.ip] = v end
for i,v in ipairs(Config.nodeList) do Config.nodeList[v.ip] = v end
for i,v in ipairs(Config.users) do Config.users[v] = v end

--add all options to globle table for easy access
--make new copys of all tables to preserve originals
function Config.setup()
	for i,v in pairs(Config) do
		local ty = type(v)
		if ty ~= "function" and ty ~= "table" then
			_G[i] = v
		elseif ty == "table" then
			_G[i] = {}
			for id,va in pairs(v) do
				_G[i][id] = va
			end
		end
	end
end
Config.setup()
--retain default settings in its own config table
--just incase we want to change settings while running we can always reset back to default using config.setup() function
_G.config = Config
return Config
