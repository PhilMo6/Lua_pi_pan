
--- Gets the next word in the given string.<br/>
-- A word is defined as the first series of unbroken alphanumeric characters.
-- Special delimiters can be defined for the word. For example, if the next
-- word starts with a single or double quote (', "), it will end with a
-- single or double quote, respectively. If neither are found after the
-- first, then it will merely return everything.<br/>
-- Also returns the remainder of the given string, if anything remains.
-- The remainder of the string has its whitespace truncated via
-- string.truncate().
function string.getWord(s)
	if not s then return nil, nil end

	local length = string.len(s)

	-- handles empty strings
	if length < 1 then
		return nil, nil
	end

	-- handles 1 character long strings
	if length == 1 then
		return s, nil
	end

	local _start, _end = 1, nil
	local first = string.sub(s, 1, 1)
	--stuff in perenthases counts as whole word
	if first == "(" then
		_end = string.find(s, "%)")
		_end = _end + 1
	-- quotation mark delimiters
	elseif first == "'" or first == "\"" then
		_start = 2
		_end = string.find(s, first, _start)
	-- space delimiter
	else
		_end = string.find(s, " ", _start)
	end

	-- grab the observed word
	local word = string.sub(s, _start, (_end and _end-1) or nil)
	-- skip whitespace after the word
	if _end and _end < length then
		_end = _end+1
	end

	return word, (_end and _end <= length and string.truncate(string.sub(s, _end))) or nil
end

--- Returns an iterator that iterates over the words within the given string.
function string.getWords(s)
	s = string.gsub(s,"\n", " ;")
	--s = string.gsub(s,",", " ,")
	local a, b = string.getWord(s)
	return function()
		-- return nil when done
		if not a then
			return nil
		end

		-- store previous iteration results
		local valueA, valueB = a, b

		-- iterate
		a,b = string.getWord(b)

		-- return previous results
		return valueA, valueB
	end
end

function string.Words(s)
	local wordsfun = string.getWords(s)
	local words = {}
	for w in wordsfun do
		table.insert(words,w)
	end
	return words
end

function string.getlines(msg)
	lines = {}
	for s in string.gmatch(msg,"(.-)\n") do
		if not string.match(s,"^\n$") then
			table.insert(lines,s)
		end
	end
	return lines
end


function string.limitMsg(msg,limit)
	msgs = {}
	local lines = string.getlines(msg)
	local c = 1
	local total = 0
	for i,v in ipairs(lines) do
		total = total + string.len(v)
		if total >= limit then
			total = 0
			c = c + 1
		end
		if msgs[c] == nil then
			msgs[c] = string.truncate(v)
		else
			msgs[c] = string.format("%s\n%s",msgs[c],string.truncate(v))
		end
	end
	return msgs
end

--- Remove whitespace from the front and back of a string.
function string.truncate(s)
	local _start, _end = 1, string.len(s)
	while _start < _end and string.sub(s, _start, _start) == " " do
		_start = _start+1
	end

	while _end > _start and string.sub(s, _end, _end) == " " do
		_end = _end-1
	end

	return string.sub(s, _start, _end)
end

function string.firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end


