local Cloneable	= require("obj.Cloneable")
local Client	= require("obj.Client")
local Master	= require("obj.Master")
local Node		= require("obj.Node")
local Server	= Cloneable.clone()

--[[
	Object used to open a TCP server.
	Creates events to connect new clients,
	check already open clients for commands,
	connect to masters if set in config,
	and ping nodes if connected.
]]


function Server:initialize(socket)
	self.clients = {}
	self.users = {}
	if socket then
		self:setSocket(socket)
	end
	--start needed events to run server
	self.serverEvents = {
	Event:new(function()--connect clients
		if not run or runningServer and not runningServer:isHosted() then
			return
		end
		local client, err = runningServer:accept()
		if not client then
			return
		end
	end, 0.1, true, 0)
	,
	Event:new(function()--accept commands from connected clients
		if not run or not runningServer and runningServer:isHosted() or #runningServer.clients < 1 then
			return
		end
		for i,v in ipairs(runningServer.clients) do
			local client = v
			local input, err = client:receive("*a")
			if err == 'closed' then
				runningServer:disconnectClient(client)
			elseif input and string.len(input) > 0 then
				local multiple = string.gmatch(input, "(.-)\n")
				local command = multiple()
				if command then
					runningServer:parseCmd(command,client)
					for cmd in multiple do
						runningServer:parseCmd(cmd,client)
					end
				else
					print(string.format("bad input from %s: {%s}", client:toString(), input))
				end
			end
		end
	end, 0.1, true, 0)
	,
	Event:new(function()--connect to master servers
		if runningServer and #masterList > 0 and #masters == 0 then
			runningServer:connectMasters()
		end
	end, 60, true, 0)
	,
	Event:new(function()--ping nodes to check connection every 5 min
		if runningServer and #nodes > 0 then
			runningServer:pingNodes()
		end
	end, timeM(5,'m'), true, 0)
	}
end

function Server:parseCmd(command,client)
	print(('TCP Command received: %s \nFrom: %s'):format(command,client:toString()))
	local s,r,com = CommandParser:parse(command,client,"tcp")
	if s then
		if r ~= false then
			if (client.node or client.master) and (com.name == "Ping" or com.name == "Pong" or com.name == "Response" or com.name == "Request") then
				if r then client:send(r) end
			elseif client.master then
				--[[if sensors and #sensors > 0 then self:parseCmd("Request SenTemp",client) end
				if lightsensors and #lightsensors > 0 then self:parseCmd("Request SenLight",client) end
				if relays and #relays > 0 then self:parseCmd("Request RlUp",client) end
				if LEDs and #LEDs > 0 then self:parseCmd("Request LEDUp",client) end
				if thermostats and #thermostats > 0 then self:parseCmd("Request ThUp",client) end]]
			elseif not client.node then
				client:send(r or "The command " .. com.name .. " has been executed.")
			end
		end
	elseif not client.node and not client.master then
		client:send(command .. " is not a valid command.")
	end
end


function Server:host(port)
	local socket = socket.tcp()

	-- bind it to the port
	_, err = socket:bind("*", port, 3)
	if not _ then
print('bind error',err)
		return false, err
	end

	-- begin listening
	local _, err = socket:listen(3)
	if not _ then
print('lisen error',err)
		return false, err
	end

	self:initializeServerSocket(socket)
	self:setSocket(socket)

	--queue necessary server events
	for i,v in ipairs(self.serverEvents) do
		Scheduler:queue(v)
	end

	return true
end

function Server:close()
	if not self:isHosted() then
		return false
	end
	for i,v in ipairs(self.clients) do
		self:disconnectClient(v)
	end
	self.socket:close()
	self.socket = nil
	return true
end

function Server:accept()
	if not self:isHosted() then
		return false
	end

	local socket, err = self.socket:accept()
	if not socket then
		return false, err
	end

	local client	= Client:new(socket)
	self:connectClient(client)
	return client
end

function Server:connectClient(client)
print('!!CONNECTED CLIENT!!',client:toString())
	self.clients[client] = client
	table.insert(self.clients, client)
	self:initializeClientSocket(client:getSocket())
	local addr, port = client:getAddress()
	if nodeList[addr] and not nodes[addr] then
		Node:new(client)
	end
	if masterList[addr] and not masters[addr] then
		Master:new(client)
		--[[if client.node then
			Scheduler:queue(Event:new(function()
				Master:new(client)
			end, 30, false))
		else
			Master:new(client)
		end]]
	end
end

function Server:disconnectClient(client)
print('!!DISCONNECTED CLIENT!!',client:toString())
	if self.clients[client] then
		self.clients[client] = nil
		table.removeValue(self.clients, client)
		local addr, port = client:getAddress()
		client:getSocket():close()
		if client.node then
			client.node:destoy()
		end
		if client.master then
			client.master:destoy()
		end
	end
end


function Server:initializeServerSocket(socket)
	socket:settimeout(0.001)
end

function Server:initializeClientSocket(socket)
	socket:settimeout(0.001)
end


function Server:setSocket(socket)
	self.socket = socket
end

function Server:isHosted()
	return (self.socket ~= nil and self.socket:getsockname() ~= nil)
end

function Server:getSocket()
	return self.socket
end

function Server:reconnectClient(client)
	if client.client then client = client.client end
	local addr, port = client:getAddress()
	self:disconnectClient(client)
	local s,err = self:connectTo(addr,port)
	if s then
		client:setSocket(s)
		self:connectClient(client)
		return true
	end
	return false
end

function Server:connectTo(addr,port)
	local s,err = socket.connect(addr,port)
	return s,err
end

function Server:ping(client)
	if client.client then client = client.client end
	print('pinging',client,os.date())
	client:send('Ping')
	if client.node and not client.node.ping then
		client.node.ping = Event:new(function()--wait 30 seconds for response
			client.node:removeSelf()
		end, 30, false)
		Scheduler:queue(client.node.ping)
	elseif client.master and not client.master.ping then
		client.master.ping = Event:new(function()--wait 30 seconds for response
			client.master:removeSelf()
		end, 30, false)
		Scheduler:queue(client.master.ping)
	end
end

function Server:pong(client)
print('ponged',client,os.date())
	if client.node and client.node.ping then
		Scheduler:dequeue(client.node.ping)
		client.node.ping = nil
	elseif client.master and client.master.ping then
		Scheduler:dequeue(client.master.ping)
		client.master.ping = nil
	end
end

function Server:connectMasters()
	for i,v in ipairs(masterList) do
		local s,err = self:connectTo(v.ip,v.port)
		if s then
			local client	= Client:new(s)
			self:connectClient(client)
			return true
		end
	end
end

function Server:pingNodes()
	for i,v in ipairs(nodes) do
		self:ping(v)
	end
end


function Server:getHTMLcontrol()

	local comm =([[%s %s]]):format(
	([[<button onclick="myFunction('stop')">Shutdown</button >]]):format(),
	([[<button onclick="myFunction('stop restart')">Restart</button >]]):format()
	)
	if nodes and #nodes > 0 then
		comm = comm ..'<br>--nodes--'
		for i,v in ipairs (nodes) do
			local com = v:getHTMLcontrol()
			comm = comm .. '<br>'..v:toString()..'<br>' .. com
		end
	end

	return comm
end

return Server
