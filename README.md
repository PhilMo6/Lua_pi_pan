Lua pi pan is a lua based home iot system for the raspberry pi.
At its heart is an event based master/node system using lua sockets
and tcp connections for a lot of the work.

A Mako web server will automatically start if set to do so in the config.lua file.
Most commands can be issued though the site as well as showing program status info.
Graphs of all recorded data are also available on the site using Flot graphs.
The default time frame displayed is one week but any length of recorded time
can be selected on the page.

An email sending and receiving system for gmail is implemented to
allow for alerts to users and if it is setup to do so also receive commands.

Direct connection and issuing of commands though tcp is also possible and some
commands not currently on the site are only accessible by doing so.

Modules are loaded on start up as needed and can be configured in the config.lua file.
All gpio work is done though these modules by calling the functions provided.
Info for each module and its functions are provided at the top of its file
located in the /objs/ folder.

Here are the loadable modules.
1w_TempSensor.lua (1 wire tempature sensor such as DS18B20)
Button.lua (physical buttons, switchs, trigger sensors such as PIR motion sensors)
Buzzer.lua (piezo buzzer)
DHT22.lua (DHT22 temp/humidity sensor)
LED.lua (LED light)
RBG_LED.lua (RBG LED light)
LightSensor.lua (photoresistor lightsensor)
MacAddressScanner.lua (uses monitor mode capable wifi to capture packets with tshark and tracks mac addresses)
MotionSensor.lua (creates button for PIR motion sensor and starts event to look for trigger events on button, if set this module will turn on relay/led/buzzer upon being triggered)
Multi_Button.lua (single pin capacitive button. This is still in testing but the concept is mostly in place.)
Relay.lua (basic relay with reverse on off pin logic(high pin = off low pin = on))
Stepper.lua (stepper motor, NOT COMPLETED!)
Thermostat.lua (checks for temperature and runs logic to maintain temperature to within its parameters)

For more info on loading modules see the config.lua file for its specific configuration requirements and examples

All "remote" prefixed modules are loaded only when a node connects to a master and represents that nodes configured modules.
Nodes will push object updates to any masters which in turn is reflected in the corresponding remote object on the master.
Commands that effect a remote object will be pushed to its node.

Command modules are located in the /objs/commands/ folder and are all
loaded at start up of the command parser.


Lua pi pan is written for lua 5.1 and is required above all else.
Rasbian has lua 5.1 installed by default.
All other dependencies can be installed easily by running the install.lua file provide with sudo.
Install will take several minutes and requires user input several times.
This will update your pi and install all needed lua libraries as well as sqlite, Mako Server, and Tshark.
It will also modify your the pi's config to look for 1 wire temperature sensors.

Lua pi pan makes use of the following external programs.
Mako Server https://makoserver.net/
Tshark https://www.wireshark.org/docs/man-pages/tshark.html
sqlite https://sqlite.org/

As well as the following libraries.
lua-sql-sqlite3
lua-socket
rpio
lua-pop3
lua-imap4

MIT License

Copyright (c) 2016 Philip Mowrey

full license found in License.txt

