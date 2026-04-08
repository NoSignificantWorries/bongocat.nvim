for cp = 0xE0FA, 0xE0FD do
	local ch = utf8.char(cp)
	print(string.format("U+%04X %s", cp, ch))
end
