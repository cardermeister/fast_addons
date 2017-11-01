function Say(...)
	
	local args = {...}
	for i,k in pairs(args) do 
		args[i] = tostring(k)
	end
	game.ConsoleCommand('say '..table.concat(args,"\r ")..'\n')

end