local Command	= require("obj.Command")

--- Request command in charge of sending and processing requests from remote nodes or masters
local Request	= Command:clone()
Request.name = "Request"
Request.keywords	= {"request"}

--- Execute the command
function Request:execute(input,user,par)
	if par == "tcp" then
		if user.node or user.master then
			return Request:subexecute(input,user,par)
		end
	end
	return false
end

function Request:subexecute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4,input5 = words[1],words[2],words[3],words[4],words[5]
	if Request.orders[input2] then--This is a valid order
		return Request.orders[input2](input3,input4,user,par)
	else
		return "That is not a vaild order."
	end
	return false
end

Request.orders = {}

Request.orders["objectUpdate"] = function(ID,user)
	if objectIDs[ID] then
		local data = "Response objectUpdate "
		local time = os.date('*t')
		local date = time.year.."-"..time.month.."-"..time.day
		time = time.hour..":"..time.min..":"..time.sec
		local stamp = os.time(os.date("*t"))
		data = ("%s |return {stamp='%s',date='%s',time='%s'"):format(data,stamp,date,time)
		local obj = objectIDs[ID]
		data = ([[%s,{id='%s',config=%s}]]):format(data,obj:getID(),obj:getConfig())
		data = ("%s}|"):format(data)
	return data
	end
end

Request.orders["objects"] = function(objs,_,user)
	if objs then
		objs = string.gsub(objs,'[%(%)]',"")
		local words = string.Words(objs)
		objs = {}
		for i,v in ipairs(words) do
			objs[v] = true
		end
	else
		objs = {}
		for i,v in ipairs(objects) do
			objs[v.name] = true
		end
	end
	local data = ("Response objects |return {id='%s'"):format(mainID)
	for i,obj in ipairs(objects) do
		if objs[obj.name] then
			data = ("%s,%s={'void'"):format(obj.name)
			for i,v in ipairs(v) do
				if not user.node or not v:isNode(user.node) then
					data = ("%s,{name='%s',id='%s',config='%s'}"):format(data,v:getName(),v:getID(),v:getConfig(true))
					if user.master then user.master:addObject(v) end
				end
			end
			data = ("%s}"):format(data)
		end
	end

	data = ("%s}|"):format(data)
	return data
end

return Request
