local Command	= require("obj.Command")

--- test command
local Button	= Command:clone()
Button.name = "Button"
Button.keywords	= {"button",'b'}

--- Execute the command
function Button:execute(input,user,par)
	local words = string.Words(input)
	local input1, input2, input3 ,input4 = words[1],words[2],words[3],words[4]

	if input2 then--input2 should be the id(pin) or index of a Button
		local button = buttons[input2] or buttons[tonumber(input2)] or buttonPins[tonumber(input2)] and buttons[buttonPins[tonumber(input2)]]
		if button then --That is a vaild Button
			if input3 then--input3 should be the order to execute
				if Button.orders[input3] then--This is a valid order
					return Button.orders[input3](button,input4,par == 'tcp' and user or nil)
				else
					return "That is not a vaild order."
				end
			else
				return "Please issue an order with the command."
			end
		else
			return "That is not a vaild Button."
		end
	else
		return "Please select a Button when issuing a Button command"
	end
end

Button.orders = {}
Button.orders["rename"] = function(button,name)
	if name then
		button:setName(name)
		updateButtonNames()
		return string.format("Button %s has been renamed %s.",button:getID(),button:getName())
	else
		return "Must supply a name to rename a Button."
	end
end
Button.orders["re"] = Button.orders["rename"]

Button.orders["press"] = function(button,f,user)
	if not button.pressed and not button:readO() then
		button:press(f,user)
		return string.format("Button %s has been pressed.",button:getName())
	else
		return string.format("Button %s already pressed.",button:getName())
	end
end




return Button
