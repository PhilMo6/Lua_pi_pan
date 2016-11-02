<?lsp title="Events" response:include".header.lsp" ?>
Database of Events
        <?lsp
		local env = luasql.sqlite() -- Create a database environment object
		local conn = env:connect("/home/pi/luaTest.db") -- Open a database file
		local cursor,errorString = conn:execute([[select * from EVENTS]])
		local row = cursor:fetch ({}, "a")
		while row do
		   print(string.format("<br>Id: %s, Stamp:%s, Event:%s", row.id, row.stamp, row.event))
		   row = cursor:fetch (row, "a")
		end
		cursor:close()
		conn:close() -- Close the database file connection object
		env:close() -- Close the database environment object
        ?>
<?lsp response:include"footer.shtml" ?>
