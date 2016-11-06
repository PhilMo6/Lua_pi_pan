local gpio_subsystem = '/sys/class/gpio/'
if not _G.usedGPIO then _G.usedGPIO = {} end

local rpio = {}
	function rpio:set_direction(direction)
		self:write(direction,self.df)
	end
	function rpio:write(value,path)
		local f = io.open(path or self.rf, 'a+')
		f:write(tostring(value))
		f:close()
	end
	function rpio:read()
		local f = io.open(self.rf, 'r')
		local value = f:read('*a')
		f:close()
		return tonumber(value)
	end
	function rpio:new(df,rf)
		local o = {}
		setmetatable(o, self)
		self.__index = self
		o.df = df
		o.rf = rf
		return o
	end

local function exists(path)
  local f = io.open(path)
  if f then
    f:close()
    return true
  else
    return false
  end
end

local function ready(device)
  return pcall(function()
    rpio:write(0,device .. 'value')
  end)
end

local function cleanup()
	for i,v in pairs(usedGPIO or {}) do v:set_direction('in') end
end

return function(which)
	if not which then return cleanup end
	local device = gpio_subsystem .. 'gpio' .. which .. '/'

	if exists(device) then
		rpio:write(which, gpio_subsystem .. 'unexport')
	end

	rpio:write(which, gpio_subsystem .. 'export')

	while not ready(device) do
		os.execute('sleep 0.001')
	end
	local d,r = device .. 'direction',device .. 'value'

	usedGPIO[which] = rpio:new(d,r)

  return usedGPIO[which]
end
