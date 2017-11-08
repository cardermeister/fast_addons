concommand.Add("discord-lua-run",function(ply)
	
	if ( IsValid(ply) ) then return end
	
	RunString(file.Read("discord-lua.txt","DATA"))
	file.Delete("discord-lua.txt")

end)