local Command	= require("obj.Command")

--- test command
local MacScanner	= Command:clone()
MacScanner.name = "MacScanner"
MacScanner.keywords	= {"macScanner","macscanner","MacScan","macscan","MacS","macs"}

--- Execute the command
function MacScanner:execute(input,user)
	if not macScanners then return "No macScanners!" end
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]
	if input2 then--input2 should be the id(pin) or index of a Thermostat
		local macScanner = macScanners[input2] or macScanners[tonumber(input2)]
		if macScanner then --That is a vaild Thermostat
			if input3 then--input3 should be the order to execute
				if MacScanner.orders[input3] then--This is a valid order
					return MacScanner.orders[input3](macScanner,input4)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild macScanner."
		end
	else
		return "Please select a macScanner when issuing a macScanner command"
	end
end

MacScanner.orders = {}
MacScanner.orders["rename"] = function(macscanner,name)
	if name then
		macscanner:setName(name)
		saveObjectsInfo()
		return string.format("MacScanner %s has been renamed %s.",macscanner:getID(),macscanner:getName())
	else
		return "Must supply a name to rename a MacScanner."
	end
end
MacScanner.orders["re"] = MacScanner.orders["rename"]

MacScanner.orders["stat"] = function(macscanner)
	return macscanner:getStatus()
end

MacScanner.orders["MacTable"] = function(macscanner,id)
	return macscanner:getMacTable(id)
end

MacScanner.orders["IDinfo"] = function(macscanner,id)
	return macscanner:getIDInfo(id)
end

MacScanner.orders["statKnown"] = function(macscanner,id)
	return macscanner:getKnownStatus(id)
end

MacScanner.orders["statFound"] = function(macscanner,id)
	return macscanner:getFoundStatus(id)
end

MacScanner.orders["statLost"] = function(macscanner,id)
	return macscanner:getLostStatus(id)
end

MacScanner.orders["toggle"] = function(macscanner)
	macscanner:toggle()
	saveObjectsInfo()
	return macscanner:toString()
end

MacScanner.orders["setState"] = function(macscanner,state)
	if state then
		macscanner:setState(state)
		return macscanner:toString()
	else
		return "Must supply a state."
	end
end

MacScanner.orders["uptime"] = function(macscanner,uptime)
	if uptime then
		macscanner:setUpTime(tonumber(uptime))
		saveObjectsInfo()
		return ("Macscanner update time now set to %s"):format(macscanner:getUpTime())
	else
		return "Must supply an uptime."
	end
end

MacScanner.orders["scanTime"] = function(macscanner,newtime)
	if newtime then
		macscanner:setScantime(tonumber(newtime))
		saveObjectsInfo()
		return ("Macscanner scan time now set to %s"):format(macscanner:getScantime())
	else
		return "Must supply an uptime."
	end
end

MacScanner.orders["timeout"] = function(macscanner,newtime)
	if newtime then
		macscanner:setTimeout(tonumber(newtime))
		saveObjectsInfo()
		return ("Macscanner time out now set to %s"):format(macscanner:getTimeout())
	else
		return "Must supply an time."
	end
end

MacScanner.orders["wlan"] = function(macscanner,wlan)
	if wlan then
		macscanner:setWlan(wlan)
		saveObjectsInfo()
		return ("Macscanner wlan now set to %s"):format(macscanner:getWlan())
	else
		return "Must supply an wlan."
	end
end


return MacScanner
