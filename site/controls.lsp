<?lsp title="Controls" response:include".header.lsp" ?>
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<script src="/rtl/jquery.js"></script>
	<script>
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
			var strip = true
			$.getJSON("index.lsp",{text,strip}, function(r) {alert(r)});
		}
		function divChange(control) {
			var text = "HTML controls2 " + control.value;
			$.getJSON("index.lsp",{text}, function(r) {
				document.getElementById("controls").innerHTML = r;
			});
		}
	</script>
	<head>
		<?lsp=TCPcommand2("HTML controls")?>
	</head>
	<body>
		<div id="controls">
			<?lsp=TCPcommand2("HTML controls2 server")?>
		</div>
	</body>
</html>
<?lsp response:include"footer.shtml" ?>
