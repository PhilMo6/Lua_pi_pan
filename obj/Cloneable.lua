local Cloneable	= {}

--[[
	Base cloneable used to clone all other modules.
]]


--- Create a pure clone of a Cloneable.
function Cloneable.clone(parent)
	local instance = {}
	setmetatable(instance, {__index=parent or Cloneable,
							__tostring=parent and parent.toString or Cloneable.toString
							}
	)
	return instance
end

--- Creates an instance-style clone of a Cloneable.
-- The clone is initialized, passing all arguments beyond the first to the clone's initialize() function.
function Cloneable.new(parent, ...)
	local c = Cloneable.clone(parent)
	c:initialize(...)
	return c
end

--- Constructor for instance-style clones.
function Cloneable:initialize(...)
end

--- Stringifier for Cloneables.
function Cloneable:toString()
	return "[cloneable]"
end

return Cloneable
