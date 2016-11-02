local Cloneable						= require("obj.Cloneable")
local Client						= Cloneable.clone()
--[[
	TCP client
]]

Client.socket						= nil
Client.user							= nil

function Client:initialize(socket)
	self:setSocket(socket)
	self.options						= {}
end

--- Returns the string-value of the Client.
-- @return A string in the format of <tt>"client@&lt;client remote address&gt;"</tt>.
function Client:toString()
	if not self.socket then
		return "client@nil"
	end
	local addr, port = self:getAddress()
	return string.format("client@%s%s%s", addr,self.master and " master"  or "",self.node and " node" or "")
end

--- Pipe to socket's receive() function.
-- Telnet protocol processing is handled before values are returned.
-- @return If successful, returns the received pattern.<br/>In case of error, the method returns nil followed by an error message.
function Client:receive(pattern, prefix)
	local _, err, input = self.socket:receive(pattern, prefix)
	if input then
		input = string.gsub(input, "\r", "")
		if string.len(input) < 1 then
			return nil, err
		end
		return input, err
	end
end

function Client:send(data, i, j)
	if not string.match(data,'\n$') then data = data .. "\n" end
	return self.socket:send(data, i, j)
end

--- Close the client's socket.
function Client:close()
	return self.socket:close()
end

--- Manually assign socket.
-- @param socket Socket to assign.
function Client:setSocket(socket)
	self.socket = socket
end

--- Retreive the client's socket.
-- @return The Client's socket.</br>nil if no socket is attached.
function Client:getSocket()
	return self.socket
end

--- Retreive the client's remote address.
-- @return The client's remote address.
function Client:getAddress()
	local addr,port = self.socket:getpeername()
	if not addr then
		if not addr then
		if self.master then addr,port = self.master:getAddress()
		elseif self.node then addr,port = self.node:getAddress()
		else addr,port = "nil" end
	end
	end
	return addr,port
end

function Client:getID()
	return self.node and self.node:getID() or ""
end

return Client
