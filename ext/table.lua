
function table.savetoString(t)
	local function prepString(st)
		st = string.gsub(st,'(\n)','\\n')
		return st
	end
	local txt = "{"
	local start = nil
	for i,v in pairs(t) do
		if start then txt = ([[%s,]]):format(txt) else start = true end
		local t1 = type(i)
		if t1 == "string" then
			txt = ([[%s["%s"]=]]):format(txt,i)
		elseif t1 == "number" then
			txt = ([[%s[%s]=]]):format(txt,i)
		end
		local t2 = type(v)
		if t2 ~= "table" then
			if t2 == "string" then
				txt = ([[%s"%s"]]):format(txt,prepString(v))
			elseif t2 == "number" then
				txt = ([[%s%s]]):format(txt,v)
			elseif t2 == "boolean" then
				txt = ([[%s%s]]):format(txt,v==true and 'true' or 'false')
			end
		else
			txt = ([[%s%s]]):format(txt,table.savetoString(v))
		end
	end
	txt = ([[%s}]]):format(txt,i)
	return txt
end

function table.writetoString(t,pre)
	if not pre then pre = '' end
	local txt = pre.."{"
	local start = nil
	for i,v in pairs(t) do
		if start then txt = ([[%s, %s ]]):format(txt,'\n') else start = true end
		local t1 = type(i)
		if t1 == "string" then
			txt = ([[%s%s%s = ]]):format(txt,pre,i)
		elseif t1 == "number" then
			txt = ([[%s%s[%s] = ]]):format(txt,pre,i)
		end
		local t2 = type(v)
		if t2 ~= "table" then
			if t2 == "string" then
				txt = ([[%s"%s"]]):format(txt,v)
			elseif t2 == "number" then
				txt = ([[%s%s]]):format(txt,v)
			elseif t2 == "boolean" then
				txt = ([[%s%s]]):format(txt,v==true and 'true' or 'false')
			end
		else
			txt = ([[%s%s]]):format(txt,table.writetoString(v,pre..' '))
		end
	end
	txt = ([[%s}]]):format(txt,i)
	return txt
end

function table.sortpairs(myTable)
	local t = {}
	for i=1,26 do
		t[i] = {}
	end
	local lastinum = 0
	for i,v in pairs(myTable) do
		local _,_,inum = string.find(i,"^(.)")
		inum = string.letterToNum(inum)
		t[inum][i] = v
	end
	return t
end

--returns the median number from a set of numbers.
function table.median(t)
  local temp={}

  -- deep copy table so that when we sort it, the original is unchanged
  -- also weed out any non numbers
  for k,v in pairs(t) do
    if type(v) == 'number' then
      table.insert( temp, v )
    end
  end

  table.sort( temp )

  -- If we have an even number of table elements or odd.
  if math.fmod(#temp,2) == 0 then
    -- return mean value of middle two elements
    return ( temp[#temp/2] + temp[(#temp/2)+1] ) / 2
  else
    -- return middle element
    return temp[math.ceil(#temp/2)]
  end
end


--- Provides a hard copy of a table, meaning all indexes within the table are copied.
function table.copy(t)
	local c = {}
	for i,v in pairs(t) do
		c[i] = v
	end

	return c
end

--- Removes a value from a table as opposed to an index.
function table.removeValue(t, value)
	for i,v in pairs(t) do
		if v == value then
			if type(i) == 'number' then
				table.remove(t, i)
			else
				t[i] = nil
			end
			return true
		end
	end

	return false
end

--- Converts the members of a table into a string, using tostring()
function table.tostring(t,delimiter)
	delimiter	= delimiter or ","

	-- empty table?
	local first	= next(t)
	if not first then
		return ""
	end

	-- one entry table?
	local second = next(t, first)
	if not second then
		return tostring(t[first])
	end

	-- unique iterator that starts at the second entry
	local iterator = function()
		local i = second
		return function()
			local index, value = i, t[i]
			i = next(t, i)
			return index, value
		end
	end

	-- generate the rest of the string
	local msg = tostring(t[first])
	for i,v in iterator() do
		msg = string.format("%s%s%s", msg, delimiter, tostring(v))
	end

	return msg
end
