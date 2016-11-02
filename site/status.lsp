<?lsp title="Status" response:include".header.lsp" ?>
<?lsp
	local status,err = TCPcommand2('status')
	print(status or err)
?>
