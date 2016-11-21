
--[[
	Mail module for sending and reciving email/sms messages.
	Set up for gmail but could be configered for any imap supported email provider.
	Iv found that reciving messages witht the current setup can be incredably slow and blocks
	the rest of the program so im going to work on fixing that.

	Note:when reciving a message it checks for messages with the label "controller".
	This allows you to whitelist with a gmail filter the addresses you wish to allow the ability to send commands your server.
]]

local smtp = require 'socket.smtp'
local ssl = require 'ssl'
local https = require 'ssl.https'

function _G.sendMessage(subject,msg,rec)
	if not mainEmail then return print('Mail send failed, email not configured') end
	--define local functions we dont want exposed gloabaly
	--these do the actual work of sending the message
	local function sslCreate()
		local sock = socket.tcp()
		return setmetatable({
			connect = function(_, host, port)
				local r, e = sock:connect(host, port)
				if not r then return r, e end
				sock = ssl.wrap(sock, {mode='client', protocol='tlsv1'})
				return sock:dohandshake()
			end
		}, {
			__index = function(t,n)
				return function(_, ...)
					return sock[n](sock, ...)
				end
			end
		})
	end
	local function send(subject,body,rec)
		local msg = {
			headers = {
				to = '<'..(rec or users[1])..'>',
				subject = subject
			},
			body = body
		}
		local ok, err = smtp.send {
			from = '<'..mainEmail..'>',
			rcpt = '<'..(rec or users[1])..'>',
			source = smtp.message(msg),
			user = mainEmail,
			password = mainEmailPass,
			server = 'smtp.gmail.com',
			port = 465,
			create = sslCreate
		}
		if not ok then--NEED TO ADD IN BETTER ERROR HANDLING
			print("Mail send failed", err)
		end
	end

	--before sending a message we need to figure out if we are going to send this to an email or a phone.
	--users are defined in Config.lua and can be assigned a protocol other then the default to be used.
	--if no user found for recipent then use default
	local protocol = usersConfigDefault.msgProtocol
	if users[rec] and usersConfig[rec] then
		protocol = usersConfig[rec].msgProtocol
		if usersConfig[rec].forwardTo then rec = usersConfig[rec].forwardTo end
	end
	if protocol == 'email' then--if email just send the message
		send(subject, msg,(rec or users[1]))
	elseif protocol == "sms" then--if sms then break up into messages no more then 150 characters long and send them
		local msgs = string.limitMsg(msg,150)
		for i,v in ipairs(msgs) do
			send(subject..(msgs[2] and i or ""), v,(rec or users[1]))
			sleep(1)
		end
	end
end

local imap4   = require "imap4"
local Message = require "pop3.message"
function _G.receiveMessage()
	if not mainEmail then return print('Mail receive failed, email not configured') end
	local connection,er = imap4('imap.gmail.com', 993, {protocol = 'tlsv1'})
	if connection then
		local logged,er = connection:login(mainEmail, mainEmailPass)
		if logged then
			local info,er = connection:examine('controller')
			if info then
				for _,v in pairs(connection:fetch('RFC822', (info.exist)..':*')) do
					local msg = Message(v.RFC822)
					connection:logout()
					return msg
				end
			else print('examine error',er)--NEED TO ADD IN BETTER ERROR HANDLING
			end
		else print('loggin error',er)--NEED TO ADD IN BETTER ERROR HANDLING
		end
		connection:logout()
	else print('connection error',er)--NEED TO ADD IN BETTER ERROR HANDLING
	end
	return nil
end
