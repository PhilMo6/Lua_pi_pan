
<?lsp title="Graphs" response:include".header.lsp" ?>
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>Graphs</title>
	<!--[if lte IE 8]><script language="javascript" type="text/javascript" src="/flot/excanvas.min.js"></script><![endif]-->
	<script language="javascript" type="text/javascript" src="/flot/jquery.js"></script>
	<script language="javascript" type="text/javascript" src="/flot/jquery.flot.js"></script>
	<script language="javascript" type="text/javascript" src="/flot/jquery.flot.time.js"></script>
	<script language="javascript" type="text/javascript" src="/flot/jquery.flot.selection.js"></script>
	<script language="javascript" type="text/javascript" src="/jquery-ui/jquery-ui.js"></script>



	<script type="text/javascript">

	<?lsp
	_ENV.sensors = {}
	local env = luasql.sqlite() -- Create a database environment object
	local conn = env:connect("/home/pi/luaTest.db") -- Open a database file
	local cursor,errorString = conn:execute("select * from MasterSensors")
	local row = cursor:fetch ({}, "a")
	while row do
		local tc = {name=row.name,loc=row.loc}
		table.insert(sensors,tc)
		sensors[row.name] = row.loc
		row = cursor:fetch (row, "a")
	end
	cursor:close()
	conn:close() -- Close the database file connection object
	env:close() -- Close the database environment object

	function getGraphData()
		local data = request:data()
		if not data.sensor then _ENV.sensor = (sensors['inside'] and 'inside' or sensors[1].name) else _ENV.sensor = data.sensor end
		if not sensors[sensor] then _ENV.lookuptable = 'temp' else _ENV.lookuptable = sensors[sensor] end
		if not data.pickeddate then _ENV.pickeddate = os.date("%Y-%m-%d",(os.time(os.date("*t")) - 604800)) else _ENV.pickeddate = data.pickeddate end
		_ENV.graphData = {}
		local env = luasql.sqlite() -- Create a database environment object
		local conn = env:connect("/home/pi/luaTest.db") -- Open a database file
		local cursor,errorString = conn:execute(([[SELECT * FROM %s WHERE (name = '%s' AND stamp BETWEEN strftime('%%s','%s','utc') AND strftime('%%s','now'))]]):format(lookuptable,sensor,pickeddate))
		local row = cursor:fetch ({}, "a")
		while row do
			local reading = row.fah or row.lightlevel or row.hum
			table.insert(graphData,{row.stamp * 1000,reading})
			_ENV.currentTemp = reading
			row = cursor:fetch (row, "a")
		end
		cursor:close()
		conn:close() -- Close the database file connection object
		env:close() -- Close the database environment object
	end
	getGraphData()
	?>

	$( function() {
		$( "#datepicker" ).datepicker({
		  defaultDate: -7
		});
		$( "#datepicker" ).datepicker( "option", "dateFormat", "yy-mm-dd" );

		$.getJSON(window.location,{}, function(d) {

			// helper for returning the weekends in a period

			function weekendAreas(axes) {

				var markings = [],
					d = new Date(axes.xaxis.min);

				// go to the first Saturday

				d.setUTCDate(d.getUTCDate() - ((d.getUTCDay() + 1) % 7))
				d.setUTCSeconds(0);
				d.setUTCMinutes(0);
				d.setUTCHours(0);

				var i = d.getTime();

				// when we don't set yaxis, the rectangle automatically
				// extends to infinity upwards and downwards

				do {
					markings.push({ xaxis: { from: i, to: i + 2 * 24 * 60 * 60 * 1000 } });
					i += 7 * 24 * 60 * 60 * 1000;
				} while (i < axes.xaxis.max);

				return markings;
			}

			var options = {
				xaxis: {
					mode: "time",
					timeformat: "%m/%d %I:%M %p",
					tickLength: 5,
					timezone: "browser"
				},
				selection: {
					mode: "x"
				},
				grid: {
					hoverable: true,
					markings: weekendAreas
				}
			};

			var plot = $.plot("#placeholder", [d], options);

			var overview = $.plot("#overview", [d], {
				series: {
					lines: {
						show: true,
						lineWidth: 1
					},
					shadowSize: 0
				},
				xaxis: {
					ticks: [],
					mode: "time"
				},
				yaxis: {
					ticks: [],
					min: 0,
					autoscaleMargin: 0.1
				},
				selection: {
					mode: "x"
				}
			});


			$("#placeholder").bind("plothover", function (event, pos, item) {
				if ($("#enablePosition:checked").length > 0) {
					var str = "(" + pos.y.toFixed(2) + ")";
					$("#hoverdata").text(str);
				}
			});


			// now connect the two

			$("#placeholder").bind("plotselected", function (event, ranges) {

				// do the zooming
				$.each(plot.getXAxes(), function(_, axis) {
					var opts = axis.options;
					opts.min = ranges.xaxis.from;
					opts.max = ranges.xaxis.to;
				});
				plot.setupGrid();
				plot.draw();
				plot.clearSelection();

				// don't fire event on the overview to prevent eternal loop


				overview.setSelection(ranges, true);
			});

			$("#overview").bind("plotselected", function (event, ranges) {
				plot.setSelection(ranges);
			});

			// Add the Flot version string to the footer

			$("#footer").prepend("Flot " + $.plot.version + " &ndash; ");
		});
	});

	</script>
</head>
<body>

	<?lsp
		local newSensor,newSensorOK = "",true

		if request:method() == "POST" then
		   local function trim(s)
			  return s and s:gsub("^%s*(.-)%s*$", "%1")
		   end
		   local data = request:data()
		   newSensor = data.sensor and trim(data.sensor)
		   newSensorOK = newSensor and sensors[newSensor]
		   if newSensorOK then
			local re = "graphs.lsp?sensor="..newSensor
			 if data.pickeddate and data.pickeddate ~= "" then re = re.."&pickeddate="..data.pickeddate end
			  response:sendredirect(re)
		   end
		end
		if request:header"x-requested-with" then
			response:json(_ENV.graphData)
		end
		?>

	<script>
		function removeDbFunction() {
			var x = document.getElementById("sensorSelect").selectedIndex;
			var y = document.getElementById("sensorSelect").options;
			var curSensorID = y[x].text;
			if (curSensorID) {
				if (confirm('Are you sure you want to remove ' + curSensorID + '?')) {
					var com = "HTML MSR ";
					var text = com + curSensorID;
					var strip = true;
					$.getJSON("index.lsp",{text,strip}, function(r) {
						alert(r);
						location.reload();
					});
				}
			}
		};
	</script>

	<div class="ui-widget ui-widget-content" >



		Sensor:<?lsp=sensor?> Date:<?lsp=_ENV.pickeddate?>
		<form method="post">
			<p>Date: <input type="text" id="datepicker" name="pickeddate"></p>
				<select id="sensorSelect" name="sensor">
				<?lsp for i,v in ipairs(sensors) do
						response:write(' <option value="'..v.name..'">'..v.name..'</option>')
					end
				?>
				</select>
			<button type="submit">Submit</button>
			<button type="button" onClick="removeDbFunction()">Remove</button>
			<br>
		</form>
		Current <?lsp=sensors[sensor]?>:<?lsp=currentTemp?>
		<div id="header">
			<h2><?lsp=sensors[sensor]:gsub("^%l", string.upper)?> Graph</h2>
			<p>
				<label><input id="enablePosition" type="checkbox" checked="checked"></input>Show data at mouse position</label>
				<span id="hoverdata"></span>
			</p>
		</div>
		<div id="content">
			<div class="demo-container">
				<div id="placeholder" class="demo-placeholder"></div>
			</div>

			<div class="demo-container" style="height:150px;">
				<div id="overview" class="demo-placeholder"></div>
			</div>

			<p>The smaller graph is linked to the main graph, so it acts as an overview. Try dragging a selection on either graph, and watch the behavior of the other.</p>

		</div>


	</div>
</body>
</html>
<?lsp response:include"footer.shtml" ?>
