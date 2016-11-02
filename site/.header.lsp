<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title><?lsp=title?></title>
	<link rel="stylesheet" href="style.css" />
	<link rel="stylesheet" href="/jquery-ui/jquery-ui.structure.min.css" />
	<link rel="stylesheet" href="/jquery-ui/jquery-ui.theme.css" />
	<?lsp
		--local styLink = ([[<link rel="stylesheet" href="/jquery-ui/jquery-ui.theme.min.%s.css" />]]):format(os.date('%B'))
		--response:write(styLink)
		?>
	<style>
		<?lsp
		local themes = {
			['January'] = {
			["#HOVERCOLOR1"]="#00e600",["#HOVERCOLOR2"]="#00e600",
			["#COLORBORDER1"]="#45930b",["#COLORBORDER2"]="#72b42d",
			['#COLORHEAD']="#3a8104",["#COLORHEAD2"]="#8bd83b",
			["#COLORBACK1"]="#3a8104",["#COLORBACK2"]="#4ca20b"
			},

			['July'] = {
			["#HOVERCOLOR1"]="#00e600",["#HOVERCOLOR2"]="#00e600",
			["#COLORBORDER1"]="#45930b",["#COLORBORDER2"]="#72b42d",
			['#COLORHEAD']="#3a8104",["#COLORHEAD2"]="#8bd83b",
			["#COLORBACK1"]="#3a8104",["#COLORBACK2"]="#4ca20b"
			},

			['August'] = {
			["#HOVERCOLOR1"]="#44372c",["#HOVERCOLOR2"]="#201913",
			["#HOVERTXT1"]="#baec7e",["#HOVERTXT2"]="#e3ddc9",
			["#COLORBORDER1"]="#695444",["#COLORBORDER2"]="#9c947c",
			['#COLORHEAD1']="#3a8104",["#COLORHEAD2"]="#201913",
			["#COLORBACK1"]="#201913",["#COLORBACK2"]="#44372c",
			['#COLORTXTHEAD']="#e3ddc9",['#COLORTXTMAIN']="#9bcc60"
			},
			['September'] = {
			["#HOVERCOLOR1"]="#44372c",["#HOVERCOLOR2"]="#201913",
			["#HOVERTXT1"]="#baec7e",["#HOVERTXT2"]="#e3ddc9",
			["#COLORBORDER1"]="#695444",["#COLORBORDER2"]="#9c947c",
			['#COLORHEAD1']="#3a8104",["#COLORHEAD2"]="#201913",
			["#COLORBACK1"]="#201913",["#COLORBACK2"]="#44372c",
			['#COLORTXTHEAD']="#e3ddc9",['#COLORTXTMAIN']="#9bcc60"
			}
		}

_G.STYLEBLANK = [[
.legendLabel
{
    color:White;
}
#nav { margin: 0 auto; width: 860px; }
#nav ul { list-style: none; }
#nav li { float:left; }
#nav a { float:left; padding: .8em 1.5em; text-decoration: none; color: #HOVERTXT1; text-shadow: 0 1px 0 rgba(255,255,255,.5); font: bold 1.1em/1 'trebuchet MS', Arial, Helvetica; letter-spacing: 1px; text-transform: uppercase; border-width: 1px; border-style: solid; border-color: #COLORBORDER1 #ccc #999 #eee; background: #COLORHEAD2; background: -moz-linear-gradient(#COLORBACK2, #COLORHEAD2); background: -webkit-linear-gradient(#COLORBACK2, #COLORHEAD2); background: -o-linear-gradient(#COLORBACK2, #COLORHEAD2); background: linear-gradient(#COLORBACK2, #COLORHEAD2); background: -ms-linear-gradient(#COLORBACK2, #COLORHEAD2); filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#COLORBACK2', endColorstr='#COLORHEAD2',GradientType=0); }
#nav a:hover, #nav a:focus { outline: 0; color: #HOVERTXT1; text-shadow: 0 1px 0 rgba(0,0,0,.2); background: #HOVERCOLOR1; background: -moz-linear-gradient(#COLORHEAD2, #HOVERCOLOR1); background: -webkit-linear-gradient(#COLORHEAD2, #HOVERCOLOR1); background: -o-linear-gradient(#COLORHEAD2, #HOVERCOLOR1); background: linear-gradient(#COLORHEAD2, #HOVERCOLOR1); background: -ms-linear-gradient(#COLORHEAD2, #HOVERCOLOR1); filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#COLORHEAD2', endColorstr='#HOVERCOLOR1',GradientType=0); }
#nav a:active { box-shadow: 0 0 2px 2px rgba(0,0,0,.3) inset; }
#nav li:first-child a { border-left: 0; border-radius: 4px 0 0 4px; }
#nav li:last-child a { border-right: 0; border-radius: 0 4px 4px 0; }
a.selected{ background: -moz-linear-gradient(#COLORHEAD2,#COLORBACK2)!important; background: -webkit-linear-gradient(#COLORHEAD2,#COLORBACK2)!important; background: -o-linear-gradient(#COLORHEAD2,#COLORBACK2)!important; background: linear-gradient(#COLORHEAD2,#COLORBACK2)!important; background: -ms-linear-gradient(#COLORHEAD2,#COLORBACK2)!important; filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#COLORHEAD2', endColorstr='#COLORBACK2',GradientType=0 )!important; }

body { background: url(background.png) repeat-x; font: 18px/1.5em "proxima-nova", Helvetica, Arial, sans-serif; }
a {	color: #069; }
a:hover { color: #28b; }
h2 { margin-top: 15px; font: normal 32px "omnes-pro", Helvetica, Arial, sans-serif; }
h3 { margin-left: 30px; font: normal 26px "omnes-pro", Helvetica, Arial, sans-serif; color: #666; }
p { margin-top: 10px; }
button { font-size: 18px; padding: 1px 7px; } input { font-size: 18px; }
input[type=checkbox] { margin: 7px; }
#maincontent { color: #HOVERTXT1; background: #COLOR3; background: linear-gradient(#COLORBACK2 , #COLORTIME ); background: -o-linear-gradient(#COLORBACK2 , #COLORTIME ); background: -ms-linear-gradient(#COLORBACK2 , #COLORTIME ); background: -moz-linear-gradient(#COLORBACK2 , #COLORTIME ); background: -webkit-linear-gradient(#COLORBACK2 , #COLORTIME ); }
#header { position: relative; width: 900px; margin: auto; }
#header h2 { margin-left: 10px; vertical-align: middle; font-size: 42px; font-weight: bold; text-decoration: none; color: #000; }
#content { width: 880px; margin: 0 auto; padding: 10px; }
#footer { margin-top: 25px; margin-bottom: 10px; text-align: center; font-size: 12px; color: #999; }
.demo-container { box-sizing: border-box; width: 850px; height: 450px; padding: 20px 15px 15px 15px; margin: 15px auto 30px auto; border: 1px solid #ddd; background: #fff; background: linear-gradient(#COLORBACK2 0, #COLORTIME 50px); background: -o-linear-gradient(#COLORBACK2 0, #COLORTIME 50px); background: -ms-linear-gradient(#COLORBACK2 0, #COLORTIME 50px); background: -moz-linear-gradient(#COLORBACK2 0, #COLORTIME 50px); background: -webkit-linear-gradient(#COLORBACK2 0, #COLORTIME 50px); box-shadow: 0 3px 10px rgba(0,0,0,0.15); -o-box-shadow: 0 3px 10px rgba(0,0,0,0.1); -ms-box-shadow: 0 3px 10px rgba(0,0,0,0.1); -moz-box-shadow: 0 3px 10px rgba(0,0,0,0.1); -webkit-box-shadow: 0 3px 10px rgba(0,0,0,0.1); }
.demo-placeholder {	width: 100%; height: 100%; font-size: 14px; line-height: 1.2em; }
.legend table { border-spacing: 5px; }
.draggable { width: 500px; height: auto; padding: 0.5em; }

.toggler { width: 500px; height: 200px; }
#button { padding: .5em 1em; text-decoration: none; }

]]
		local sty = STYLEBLANK
		sty = string.gsub(sty,'#COLORTIME','#fff')
		local theme = themes['July'] --themes[os.date('%B')]
		for i,v in pairs(theme) do
			sty = string.gsub(sty,i,v)
		end
		response:write(sty)
		?>
	</style>
</head>
<body>
<div id="nav" style="padding: 0; margin: 0; vertical-align: top;"><ul>
	<?lsp
		_G.MASTERlinks={}
		local env = luasql.sqlite() -- Create a database environment object
		local conn = env:connect("/home/pi/luaTest.db") -- Open a database file
		local cursor,errorString = conn:execute("select * from MASTERLinks")
		local row = cursor:fetch ({}, "a")
		while row do
			table.insert(MASTERlinks,{row.link .. '.lsp',row.link:gsub("^%l", string.upper)})
			row = cursor:fetch (row, "a")
		end
		cursor:close()
		conn:close() -- Close the database file connection object
		env:close() -- Close the database environment object

		for _,link in ipairs(MASTERlinks) do
		   local isactive = title == link[2]
		   response:write('<li><a href="',link[1],'"', isactive and ' class="selected"' or '','>',link[2],'</a></li>')
		end

	?>
</ul></div>

<div id="maincontent">
