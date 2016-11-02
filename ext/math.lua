
function math.round(num,to)
	if to == nil then to = 10 end
	local roundto=to
	if num*roundto<0 then x=-.5 else x=.5 end
	local Integer, decimal = math.modf(num*roundto+x)
	local result = Integer/roundto
	return result
end

