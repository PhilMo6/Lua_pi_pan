<?lsp title="Dashboard" response:include".header.lsp" ?>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>jQuery UI Draggable - Default functionality</title>

  <script src="https://code.jquery.com/jquery-1.12.4.js"></script>
  <script src="https://code.jquery.com/ui/1.12.0/jquery-ui.js"></script>
  <script>
  $( function() {
    $( "#draggable" ).draggable();
	$( "#draggable" ).resizable({
      animate: true
    });
	$( "#draggable2" ).draggable();
	$( "#draggable2" ).resizable({
      animate: true
    });
	function runEffect() {
      // get effect type from
	  var toeffect = $( "#toeffect" ).val();
      // Run the effect
      $( toeffect ).toggle( "blind" );
    };
    // Set effect from select menu value
    $( "#button" ).on( "click", function() {
      runEffect();
    });

	$( "#dialog" ).dialog({
      autoOpen: false,
      show: {
        effect: "blind",
        duration: 1000
      },
      hide: {
        effect: "blind",
        duration: 1000
      }
    });

  } );


  function myFunction(text,formID) {
		if (formID) {
			var f = document.getElementById(formID);
			if (f) {
				var x = f.elements["com"].value;
					if (x) {
					var text = text.concat(" ",x);
				}
			}
		}
		$.getJSON("index.lsp",{text}, function(r) {
			if (r) {
				var re = "<p>" + r + "</p>";
				document.getElementById("dialog").innerHTML = re;
				$( "#dialog" ).dialog( "open" );
			}
		});
	}
	function divChangeTo(divID,to) {
		document.getElementById(divID).innerHTML = to;
	}
	function divChange(control) {
		var text = "HTML controls2 " + control.value;
		$.getJSON("index.lsp",{text}, function(r) {
			document.getElementById("controls").innerHTML = r;
		});
	}


  </script>

</head>
<body>

<select name="widgets" id="toeffect">
  <option value="#draggable">Controls</option>
  <option value="#draggable2">Status</option>
</select>
<button id="button" class="ui-state-default ui-corner-all">Add/Remove</button>

<div class="ui-widget">
	<div id="dialog" title="Reply">	</div>


	<div id="draggable" style="overflow: hidden; draggable;">
	  <h3 class="ui-widget-header"><?lsp=TCPcommand2("HTML controls")?> </h3>
	  <div id="controls" class="ui-widget-content">
	   <p>
		<?lsp=TCPcommand2("HTML controls2 server")?>
		</p>
	  </div>
	</div>

	<div id="draggable2"  style="overflow: hidden;" >
	  <h3 class="ui-widget-header">Status</h3>
	  <div id="statuswiget" class="ui-widget-content">
		<?lsp=TCPcommand2("status")?>
	  </div>
	</div>
</div>



</body>
</html>
<?lsp response:include"footer.shtml" ?>
