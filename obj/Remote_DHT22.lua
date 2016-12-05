local Cloneable			= require("obj.Sensor")
local origin 			= require("obj.DHT22")
local DHT22			= Cloneable:clone()
--[[
	Remote object for DHT22 sensors attached to nodes.
	Node will update the remote sensors last read as the sensors tempature/humidity changes.
]]

DHT22.location = origin.location
DHT22.getHTMLcontrol = origin.getHTMLcontrol

function DHT22:setup(options)
	self.lastTRead = 0
	self.lastHRead = 0
end

function DHT22:updateLastRead(lr)
	local hv,tv = lr:match('(%d+)|(%d+)')
	self.config.lastRead = lr
	if hv then
		local up = (self.lastHRead ~= hv and true or self.lastTRead ~= tv and true or nil)
		self.lastHRead = hv
		self.lastTRead = tv
		if up then
			self:updateMasters()
		end
	end
end

function DHT22:pollSensor()
	return self:getLastRead()
end

function DHT22:getLastRead()
	return self.lastHRead,self.lastTRead
end

--- Stringifier for Cloneables.
function DHT22:toString()
	local t,h = self:getLastRead()
	return string.format("[Remote_DHT22] %s %s %sC %s%%",self:getID(),self:getName(),t or 'nil',h or 'nil')
end

return DHT22
