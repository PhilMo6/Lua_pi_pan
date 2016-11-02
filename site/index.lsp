<?lsp
	if request:header"x-requested-with" then
		local data = request:data()
		if data.text then
			local r,er = TCPcommand2(data.text)
			local res = r or er
			res = string.gsub(res,'<br>$','')
			if data.strip then
				res = string.gsub(res,'<br>','\n')
			end
			response:json({res})
		else
			response:json({"error"})
		end
	else
		response:include".header.lsp"
		response:sendredirect(MASTERlinks[1][1])
	end
?>
