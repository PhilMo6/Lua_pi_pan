print('Prepairing to install Lua Pi Pan!')
--First update to make sure all packages can be gotten then install external programs that are used.
--After update make and install mako server then install tshark.
os.execute([[sudo apt-get update ; cd ; sudo wget http://makoserver.net/download/mako.raspberrypi.tar.gz ; sudo tar xvzf mako.raspberrypi.tar.gz ; sudo cp mako mako.zip  /usr/bin/ ; sudo apt-get install tshark]])
--Once external programs are installed install required librarys.
os.execute([[sudo apt-get install luarocks ; sudo apt-get install lua-sec ; sudo apt-get install sqlite ; sudo apt-get install lua-sql-sqlite3 ; sudo apt-get install lua-socket ; sudo luarocks install pop3]])
os.execute([[cd /home/pi/Lua_pi_pan/source ; cc -o wpiLuaWrap.so wpiLuaWrap.c -shared -I/usr/include/lua5.1 -llua5.1 -lwiringPi ; cd ..]])

--In order for 1 wire tempature sensors to work the pi must be configured to look for them.
local f = assert(io.open("/boot/config.txt", "a"))
f:write("\ndtoverlay=w1-gpio")
f:close()

--setup auto start script
local f = assert(io.open('/etc/init.d/lppan','w'))
f:write([[#! /bin/sh
cd /home/pi/Lua_pi_pan
sudo lua main.lua
]])
f:close()
os.execute('sudo update-rc.d lppan remove')
os.execute('sudo chmod 755 /etc/init.d/lppan')
os.execute('sudo update-rc.d lppan defaults')

--After this is done last thing is to restart!
print('Install compleate will restart in 10 seconds!\n Soon you can start whipping up a recipe for your Lua Pi Pan!')
os.execute("sleep 5;sudo reboot")
